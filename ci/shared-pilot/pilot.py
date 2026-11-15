#!/usr/bin/env python3
"""Bounded, signed-cache integration pilot for the shared execution planner."""

import argparse
from collections import Counter
import json
import os
from pathlib import Path
import re
import subprocess
import time


CACHES = ["https://anmonteiro.nix-cache.workers.dev", "https://cache.nixos.org"]
MAX_DERIVATIONS = 6
MAX_BOUNDARY_BYTES = 2 * 1024**3
SETS = {"native-5_5", "native-5_6", "musl-5_5", "musl-5_6"}


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def read_json(path):
    return json.loads(Path(path).read_text())


def write_json(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + "\n")


def command(argv, *, capture=False):
    return subprocess.run(argv, check=True, text=True,
                          stdout=subprocess.PIPE if capture else None).stdout


def nix_json(*args):
    return json.loads(command(["nix", *args], capture=True))


def store_path(path):
    return path if path.startswith("/") else "/nix/store/" + path


def derivations(paths):
    value = nix_json("derivation", "show", *sorted(paths))
    result = {}
    for drv, node in value.get("derivations", value).items():
        env = node.get("env", {})
        structured = node.get("structuredAttrs", {}) or json.loads(env.get("__json", "{}"))
        result[store_path(drv)] = {
            "name": node["name"],
            "pname": structured.get("pname", env.get("pname", "")),
            "system": node["system"],
            "inputs": [store_path(dep) for dep in node.get(
                "inputDrvs", node.get("inputs", {}).get("drvs", {}))],
        }
    return result


def prepare(args):
    started = time.time()
    source = Path(args.source).resolve()
    plan = Path(args.plan)
    wrapper = Path(args.wrapper).resolve()
    wrapper.mkdir(parents=True, exist_ok=False)
    # A Git-filtered immutable snapshot excludes tool/store and reports created
    # by earlier workflow steps. The temporary wrapper carries its own selector
    # and a locked local input, so nix-eval-jobs can evaluate it in pure mode.
    snapshot = Path(nix_json("flake", "archive", "--json", str(source))["path"])
    (wrapper / "sets.nix").write_text((snapshot / "ci/shared-pilot/sets.nix").read_text())
    (wrapper / "flake.nix").write_text(
        "{ inputs.overlays.url = " + json.dumps("path:" + str(snapshot)) + "; "
        "outputs = { overlays, ... }: import ./sets.nix { inherit overlays; }; }\n")
    command(["nix", "flake", "lock", "path:" + str(wrapper)])
    expression = ("import " + str(snapshot / "ci/shared-pilot/sets.nix")
                  + " { overlays = builtins.getFlake "
                  + json.dumps("path:" + str(snapshot)) + "; }")
    selected = nix_json("eval", "--impure", "--json", "--expr",
        "let sets = " + expression + "; in builtins.mapAttrs (_: packages: "
        "builtins.mapAttrs (_: p: { derivation = p.drvPath; output = p.outPath; "
        "name = p.name; }) packages) sets")
    require(set(selected) == SETS, "The four pilot scopes changed")
    require(all(set(packages) == {"lwt"} for packages in selected.values()),
            "The selected package family changed")
    roots = {package["derivation"] for packages in selected.values() for package in packages.values()}
    require(len(roots) == 4, "Expected four distinct native/musl package roots")
    recipes = derivations(roots)
    # Resolve compiled libraries from actual input edges. Native and musl libev
    # differ, while each is identical across the two OCaml compiler versions.
    helper_pattern = re.compile(r"/nix/store/[a-z0-9]{32}-libev(?:-x86_64-unknown-linux-musl)?-[0-9.]+\.drv$")
    helpers = {dep for node in recipes.values() for dep in node["inputs"]
               if helper_pattern.fullmatch(dep)}
    require(len(helpers) == 2 and len(roots | helpers) <= MAX_DERIVATIONS,
            "Expected exactly two compiled libev helpers within the six-derivation budget")
    helper_recipes = derivations(helpers)
    require(all(node["pname"] == "libev" for node in helper_recipes.values()),
            "A selected helper is not libev")
    require(all(len(set(node["inputs"]) & helpers) == 1 for node in recipes.values()),
            "Each selected root must consume one exact libev helper")
    selection = {
        "version": 1, "sets": selected, "allowedDerivations": sorted(roots | helpers),
        "helpers": helper_recipes,
        "helperConsumers": {drv: sorted(set_id for set_id, packages in selected.items()
            if any(drv in recipes[p["derivation"]]["inputs"] for p in packages.values()))
            for drv in sorted(helpers)},
        "maxDerivations": MAX_DERIVATIONS, "maxBoundaryNarBytes": MAX_BOUNDARY_BYTES,
        "sourceSnapshot": str(snapshot), "evaluationLock": read_json(wrapper / "flake.lock"),
        "startedAt": started, "finishedAt": time.time(),
    }
    selection["durationSeconds"] = selection["finishedAt"] - started
    write_json(plan / "selection.json", selection)
    write_json(plan / "sets.json", {
        "sets": [{"id": name, "flake": "path:" + str(wrapper) + "#" + name}
                 for name in sorted(selected)],
        "runners": {"x86_64-linux": "ubuntu-latest"},
    })


def validate_plan(manifest, selection):
    allowed = set(selection["allowedDerivations"])
    require(len(allowed) <= MAX_DERIVATIONS, "Allowlist exceeds the fixed build budget")
    expected = {set_id: {package["derivation"] for package in packages.values()}
                for set_id, packages in selection["sets"].items()}
    requests = manifest["plan"]["requests"]
    observed = {request["id"]: {root["drvPath"] for root in request["roots"]}
                for request in requests}
    require(len(requests) == len(expected) and observed == expected,
            "Planned package roots differ from the evaluated pilot selection")
    groups = manifest["plan"]["groups"]
    members = [drv for group in groups for drv in group["members"]]
    unexpected = sorted(set(members) - allowed)
    require(not unexpected,
            "Cold dependencies exceed this pilot's budget; warm them in the ordinary pipeline first: "
            + ", ".join(unexpected))
    require(len(members) == len(set(members)), "A derivation has more than one owner")
    require(len(members) <= MAX_DERIVATIONS, "Plan exceeds the fixed build budget")
    require(all(group["system"] == "x86_64-linux" for group in groups),
            "This pilot only executes x86_64-linux jobs")
    require(all(group["kind"] in {"shared", "package"} for group in groups),
            "Unexpected execution stage")
    graph = manifest["graph"]
    owned_outputs = {path for drv in members for path in graph[drv]["outputs"].values() if path}
    boundary = {path for group in groups for path in group["requiredPaths"]} - owned_outputs
    require(boundary <= set(manifest["cachedPaths"]), "A boundary was not found in the read caches")
    return {"ownedDerivations": sorted(members), "cachedBoundaryPaths": sorted(boundary),
            "sharedGroups": sum(group["kind"] == "shared" for group in groups),
            "packageGroups": sum(group["kind"] == "package" for group in groups),
            "warm": not groups}


def guard(args):
    started = time.time()
    plan = Path(args.plan)
    result = {"startedAt": started, "status": "failed"}
    try:
        manifest = read_json(plan / "execution-plan.json")
        selection = read_json(plan / "selection.json")
        result.update(validate_plan(manifest, selection))
        closure = {}
        providers = {}
        for path in result["cachedBoundaryPaths"]:
            for cache in CACHES:
                probe = subprocess.run(["nix", "path-info", "--store", cache,
                    "--recursive", "--json", path], text=True, capture_output=True)
                if probe.returncode:
                    continue
                values = json.loads(probe.stdout)
                if isinstance(values, list):
                    values = {value["path"]: value for value in values if value}
                if path not in values or not all(values.values()):
                    continue
                providers[path] = cache
                closure.update(values)
                break
            require(path in providers, "No complete cached boundary closure: " + path)
        nar_bytes = sum(value["narSize"] for value in closure.values())
        require(nar_bytes <= MAX_BOUNDARY_BYTES,
                "Distinct cached boundary NAR content exceeds 2 GiB: " + str(nar_bytes))
        result.update(status="success", boundaryNarBytes=nar_bytes,
                      boundaryPaths=len(closure), providers=providers)
        write_json(plan / "boundary-closure.json", closure)
        print("Bounded plan: %d owned derivations, %d prerequisite groups, %d package groups; "
              "%.1f MiB cached boundary" % (len(result["ownedDerivations"]),
              result["sharedGroups"], result["packageGroups"], nar_bytes / 1024**2))
    except Exception as error:
        result["error"] = str(error)
        raise
    finally:
        result.update(finishedAt=time.time(), durationSeconds=time.time() - started)
        write_json(plan / "bounded-work.json", result)


def plan_sets(args):
    started = time.time()
    metadata = {"startedAt": started, "status": "failed"}
    try:
        argv = ["nix-ci-build", "--plan-sets", str(Path(args.plan) / "sets.json"),
                "--report-dir", args.plan, "--jobs", "2"]
        for cache in CACHES:
            argv += ["--copy-from", cache]
        command(argv)
        metadata["status"] = "success"
    except Exception as error:
        metadata["error"] = str(error)
        raise
    finally:
        metadata.update(finishedAt=time.time(), durationSeconds=time.time() - started)
        write_json(Path(args.plan) / "planning.json", metadata)


def identity(group):
    return {"groupId": group, "runId": os.environ["NIX_CI_BUILD_RUN_ID"],
            "attemptId": os.environ["NIX_CI_BUILD_ATTEMPT_ID"]}


def bootstrap(args):
    started = time.time()
    directory = Path(args.tool)
    metadata = {"startedAt": started, "status": "failed", "operation": args.operation}
    if args.group:
        metadata.update(identity(args.group))
    try:
        if args.operation == "export":
            directory.mkdir(parents=True, exist_ok=True)
            tool = command(["nix", "build", "--accept-flake-config", "-L", "--no-link",
                            "--print-out-paths", args.flake], capture=True).strip()
            built = time.time()
            require(len(tool.splitlines()) == 1 and tool.startswith("/nix/store/"),
                    "Builder bootstrap must produce exactly one store path")
            (directory / "path").write_text(tool + "\n")
            write_json(directory / "closure.json", nix_json("path-info", "--recursive", "--json", tool))
            signing_key = Path.home() / ".nix/nix-cache-key.sec"
            require(signing_key.is_file(), "The existing R2 cache action did not configure its signing key")
            destination = (directory / "store").resolve().as_uri() + "?compression=zstd&secret-key=" + str(signing_key)
            command(["nix", "copy", "--to", destination, tool])
            metadata.update(buildSeconds=built - started, exportSeconds=time.time() - built)
        else:
            tool = (directory / "path").read_text().strip()
            require(re.fullmatch(r"/nix/store/[a-z0-9]{32}-[^/\n]+", tool), "Invalid builder artifact path")
            command(["nix", "copy", "--from", (directory / "store").resolve().as_uri(), tool])
        metadata.update(toolPath=tool, status="success")
        if os.environ.get("GITHUB_PATH"):
            with open(os.environ["GITHUB_PATH"], "a") as stream:
                stream.write(tool + "/bin\n")
    except Exception as error:
        metadata["error"] = str(error)
        raise
    finally:
        metadata.update(finishedAt=time.time(), durationSeconds=time.time() - started)
        write_json(Path(args.report) / "bootstrap.json", metadata)


def execute(args):
    report = Path(args.report)
    started = time.time()
    record = {**identity(args.group), "startedAt": started, "status": "failed"}
    try:
        validate_plan(read_json(Path(args.plan) / "execution-plan.json"),
                      read_json(Path(args.plan) / "selection.json"))
        destination = ("s3://overlays?endpoint=https://7a53c28e9b7a91239f9ed42da04276bc.r2.cloudflarestorage.com"
                       "&region=auto&compression=zstd&parallel-compression=true&secret-key="
                       + str(Path.home() / ".nix/nix-cache-key.sec"))
        argv = ["nix-ci-build", "--execute-plan", args.plan, "--group", args.group,
                "--copy-to", destination, "--report-dir", args.report,
                "--jobs", "2", "--retries", "0"]
        for cache in CACHES:
            argv += ["--copy-from", cache]
        command(argv)
        record["status"] = "success"
    except Exception as error:
        record["error"] = str(error)
        raise
    finally:
        record.update(finishedAt=time.time(), durationSeconds=time.time() - started)
        write_json(report / "pilot-worker.json", record)


def summarize(args):
    plan = Path(args.plan)
    output = Path(args.report)
    aggregate = read_json(output / "aggregate.json") if (output / "aggregate.json").is_file() else {}
    selection = read_json(plan / "selection.json")
    manifest = read_json(plan / "execution-plan.json")
    guarded = read_json(plan / "bounded-work.json")
    owned = {drv: group["id"] for group in manifest["plan"]["groups"] for drv in group["members"]}
    observed = Counter()
    attempts = Counter()
    violations = []
    incomplete = []
    workers = []
    build_seconds = 0.0
    for group in aggregate.get("groups", []):
        # Reuse the aggregate's run/attempt selection. A failed prior attempt
        # must not turn a successful retry into a duplicate-owner violation.
        active = [attempt for attempt in group["attempts"]
                  if attempt["runId"] == aggregate["activeRunId"]]
        for attempt in active:
            for item in attempt.get("actual", {}).get("derivations", []):
                if (item.get("buildSeconds") or 0) > 0:
                    attempts[item["drvPath"]] += 1
        current = [attempt for attempt in active if attempt["attemptId"] == group["latestAttemptId"]]
        if group.get("ambiguousAttemptOrder") or len(current) != 1:
            incomplete.append(group["id"])
            continue
        attempt = current[0]
        actual = attempt.get("actual", {})
        if "derivations" not in actual:
            incomplete.append(group["id"])
        built = [item for item in actual.get("derivations", []) if (item.get("buildSeconds") or 0) > 0]
        worker = {"groupId": group["id"], "runId": attempt["runId"], "attemptId": attempt["attemptId"],
                  "status": attempt["status"], "startedAt": attempt.get("startedAt"),
                  "finishedAt": attempt.get("finishedAt"), "phases": attempt.get("phases", []),
                  "observedBuilds": [{"drvPath": item["drvPath"], "buildSeconds": item["buildSeconds"],
                                      "state": item["state"]} for item in built]}
        for item in built:
            observed[item["drvPath"]] += 1
            build_seconds += item["buildSeconds"]
            if owned.get(item["drvPath"]) != worker["groupId"]:
                violations.append(item["drvPath"])
        workers.append(worker)
    missing = sorted({group["id"] for group in manifest["plan"]["groups"]}
                     - {worker["groupId"] for worker in workers})
    duplicates = {drv: count for drv, count in observed.items() if count > 1}
    bootstrap = read_json(plan / "bootstrap.json") if (plan / "bootstrap.json").is_file() else {}
    planning = read_json(plan / "planning.json") if (plan / "planning.json").is_file() else {}
    timed = all(w["startedAt"] is not None and w["finishedAt"] is not None for w in workers)
    wall = (max(w["finishedAt"] for w in workers) - min(w["startedAt"] for w in workers)) if workers and timed else 0 if not workers else None
    result = {"version": 1, "case": "natural-cache", "guard": guarded,
              "workers": workers, "observedBuildCounts": dict(observed),
              "allAttemptBuildCounts": dict(attempts),
              "observedBuildActivitySeconds": build_seconds,
              "duplicateBuilds": duplicates, "ownershipViolations": violations,
              "missingWorkerReports": missing, "incompleteWorkerReports": sorted(set(incomplete)),
              "toolBootstrap": bootstrap, "planning": planning,
              "bootstrapToAggregateSeconds": time.time() - bootstrap["startedAt"] if bootstrap else None,
              "workerWallSeconds": wall,
              "status": "success" if aggregate.get("status") == "success" and guarded["status"] == "success"
                  and not missing and not incomplete and not duplicates and not violations
                  and all(w["status"] == "success" for w in workers) else "failed"}
    write_json(output / "pilot-measurements.json", result)
    lines = ["# Shared prerequisite pilot", "", "Status: **" + result["status"] + "**", "",
             "Four real OCaml 5.5/5.6 native/musl scopes, with `lwt` in each.", "",
             "| Measurement | Observed |", "| --- | ---: |",
             f"| Package roots | {sum(len(p) for p in selection['sets'].values())} |",
             f"| Planned derivations to build | {len(owned)} |",
             f"| Derivations with observed build activity | {sum(observed.values())} |",
             f"| Derivations built by multiple workers | {len(duplicates)} |",
             f"| Summed build activity | {build_seconds:.2f} s |",
             "| Worker wall span | " + (f"{wall:.2f} s" if wall is not None else "Unknown") + " |",
             f"| Cached boundary NAR content | {guarded.get('boundaryNarBytes', 0) / 1024**2:.1f} MiB |", ""]
    if not owned:
        lines += ["All roots were already cached. Both worker matrices were correctly skipped; "
                  "this run validates warm planning and reporting, and does not demonstrate a build speedup.", ""]
    if bootstrap:
        lines += [f"Tool bootstrap: {bootstrap['durationSeconds']:.2f} s. "
                  f"Bootstrap to this combined report: {result['bootstrapToAggregateSeconds']:.2f} s.", ""]
    if planning:
        lines += [f"Planning: {planning['durationSeconds']:.2f} s.", ""]
    lines += ["The original signed production cache is used throughout. No outputs are invalidated "
              "and no independent baseline is run against a cache warmed by this pilot. "
              "Build activity is elapsed Nix build time, not CPU time. Worker wall span includes "
              "gaps between stages; tool bootstrap and imports are retained separately in the reports. "
              "Current measurements use the combined report's selected attempts; earlier retries remain in its history.", ""]
    if missing:
        lines += ["Missing worker reports: " + ", ".join(missing), ""]
    (output / "pilot-summary.md").write_text("\n".join(lines))
    require(result["status"] == "success", "Pilot did not complete within its ownership guarantees")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    prepare_parser = commands.add_parser("prepare")
    prepare_parser.add_argument("--source", default=".")
    prepare_parser.add_argument("--plan", default="plan")
    prepare_parser.add_argument("--wrapper", required=True)
    prepare_parser.set_defaults(function=prepare)
    guard_parser = commands.add_parser("guard")
    guard_parser.add_argument("--plan", default="plan")
    guard_parser.set_defaults(function=guard)
    plan_parser = commands.add_parser("plan")
    plan_parser.add_argument("--plan", default="plan")
    plan_parser.set_defaults(function=plan_sets)
    bootstrap_parser = commands.add_parser("bootstrap")
    bootstrap_parser.add_argument("operation", choices=["export", "import"])
    bootstrap_parser.add_argument("--tool", default="tool")
    bootstrap_parser.add_argument("--report", required=True)
    bootstrap_parser.add_argument("--group")
    bootstrap_parser.add_argument("--flake")
    bootstrap_parser.set_defaults(function=bootstrap)
    execute_parser = commands.add_parser("execute")
    execute_parser.add_argument("--plan", default="plan")
    execute_parser.add_argument("--report", default="report")
    execute_parser.add_argument("--group", required=True)
    execute_parser.set_defaults(function=execute)
    summary_parser = commands.add_parser("summarize")
    summary_parser.add_argument("--plan", default="plan")
    summary_parser.add_argument("--reports", default="reports")
    summary_parser.add_argument("--report", default="aggregate")
    summary_parser.set_defaults(function=summarize)
    args = parser.parse_args()
    args.function(args)


if __name__ == "__main__":
    main()
