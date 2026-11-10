#!/usr/bin/env python3
"""Publish a bounded report archive from Actions data, never from artifact HTML."""

import argparse
import base64
import collections
import datetime as dt
import hashlib
import html
import io
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import stat
import subprocess
import tempfile
import zipfile


ARCHIVE_BRANCH = "build-reports"
MAX_ARTIFACT_BYTES = 256 * 1024 * 1024
MAX_DATA_BYTES = 32 * 1024 * 1024
MAX_EVENTS_BYTES = 64 * 1024 * 1024
MAX_REPORT_BYTES = 64 * 1024 * 1024
MAX_ARCHIVE_BYTES = 512 * 1024 * 1024
ARTIFACT_NAME = re.compile(r"^nix-ci-build-[A-Za-z0-9_.-]+-attempt-([1-9][0-9]*)$")
SHA = re.compile(r"^[a-f0-9]{40}$")
REPOSITORY = re.compile(r"^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$")


def positive(value):
    number = int(value)
    if number < 1:
        raise ValueError("expected a positive integer")
    return number


def escape(value):
    return html.escape(str(value), quote=True)


def decode_json(data):
    def invalid_constant(_):
        raise ValueError("non-finite JSON number")

    try:
        return json.loads(data, parse_constant=invalid_constant)
    except RecursionError as error:
        raise ValueError("JSON nesting exceeds the limit") from error


class GitHub:
    def __init__(self, repository):
        if not REPOSITORY.fullmatch(repository):
            raise ValueError("invalid repository")
        self.repository = repository
        self.prefix = "repos/" + repository + "/"

    def request(self, endpoint, *, binary=False, missing=False, limit=MAX_ARCHIVE_BYTES):
        # gh handles authentication and authenticated redirects. Never evaluate a
        # command or URL supplied by a build artifact.
        with tempfile.TemporaryFile() as output:
            result = subprocess.run(
                ["gh", "api", self.prefix + endpoint],
                stdout=output, stderr=subprocess.PIPE, timeout=180,
            )
            size = output.tell()
            if size > limit:
                raise ValueError("GitHub response exceeds the size limit")
            output.seek(0)
            data = output.read()
        if result.returncode:
            if missing:
                try:
                    if str(decode_json(data).get("status")) == "404":
                        return None
                except (ValueError, AttributeError):
                    pass
            raise RuntimeError("GitHub API request failed: " + endpoint.split("?")[0])
        return data if binary else decode_json(data)

    def pages(self, endpoint, key):
        result = []
        for page in range(1, 21):
            separator = "&" if "?" in endpoint else "?"
            data = self.request(f"{endpoint}{separator}per_page=100&page={page}")
            items = data[key] if key else data
            result.extend(items)
            if len(items) < 100:
                return result
        raise ValueError("GitHub result exceeds the pagination limit")


def safe_archive_path(name):
    path = PurePosixPath(name)
    if path.is_absolute() or ".." in path.parts or "\\" in name:
        raise ValueError("unsafe archive path")
    return path


def regular_member(info):
    mode = info.external_attr >> 16
    return not mode or stat.S_IFMT(mode) in (0, stat.S_IFREG)


def read_report_member(archive, info):
    try:
        return archive.read(info)
    except (NotImplementedError, RuntimeError) as error:
        raise ValueError("unsupported or encrypted report data") from error


def artifact_data(data):
    """Read only the two known data files; do not extract HTML, scripts or logs."""
    result = {}
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        if len(archive.infolist()) > 10000:
            raise ValueError("too many artifact entries")
        for info in archive.infolist():
            safe_archive_path(info.filename)
            if info.filename not in ("results.json", "events.jsonl"):
                continue
            if info.filename in result or not regular_member(info):
                raise ValueError("duplicate or non-regular report data")
            limit = MAX_DATA_BYTES if info.filename == "results.json" else MAX_EVENTS_BYTES
            if info.file_size > limit:
                raise ValueError("report data exceeds the size limit")
            result[info.filename] = read_report_member(archive, info)
    if "results.json" not in result:
        raise ValueError("artifact does not contain results.json")
    snapshot = decode_json(result["results.json"])
    if not isinstance(snapshot, dict) or snapshot.get("schemaVersion") != 1:
        raise ValueError("unsupported report schema")
    if not isinstance(snapshot.get("jobs", []), list):
        raise ValueError("invalid report jobs")
    events, notes = [], []
    raw_events = result.get("events.jsonl", b"")
    lines = raw_events.splitlines()
    for number, line in enumerate(lines):
        if line.strip():
            try:
                event = decode_json(line)
            except ValueError:
                if number == len(lines) - 1 and not raw_events.endswith((b"\n", b"\r")):
                    notes.append("The final event was incomplete; the timeline includes all earlier complete events.")
                    break
                raise
            if not isinstance(event, dict):
                raise ValueError("invalid report event")
            events.append(event)
            if len(events) > 200000:
                raise ValueError("too many report events")
    return snapshot, events, notes


def restore_archive(api, site):
    ref = api.request("git/ref/heads/" + ARCHIVE_BRANCH, missing=True)
    if ref is None:
        return {"version": 1, "repository": api.repository, "runs": []}, ""
    revision = ref["object"]["sha"]
    if not SHA.fullmatch(revision):
        raise ValueError("invalid archive revision")
    data = api.request("zipball/" + revision, binary=True)
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        members = archive.infolist()
        if len(members) > 10000 or sum(i.file_size for i in members) > MAX_ARCHIVE_BYTES:
            raise ValueError("archive exceeds the size limit")
        for info in members:
            source = safe_archive_path(info.filename)
            parts = source.parts[1:]  # GitHub zipballs have one repository directory.
            if not parts or info.is_dir():
                continue
            if not regular_member(info) or ".git" in parts:
                raise ValueError("non-regular file in report archive")
            destination = site.joinpath(*parts)
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(archive.read(info))
    catalog = decode_json((site / "catalog.json").read_bytes())
    if catalog.get("version") != 1 or catalog.get("repository") != api.repository:
        raise ValueError("archive belongs to another repository or schema")
    for run in catalog["runs"]:
        positive(run["id"])
        positive(run["attempt"])
        if not SHA.fullmatch(run["headSha"]):
            raise ValueError("invalid archived commit")
    return catalog, revision


def run_path(run):
    return f"runs/{positive(run['id'])}/{positive(run['attempt'])}"


def branch_path(run):
    label = run["headRepository"] + "/" + run["headBranch"]
    slug = re.sub(r"[^A-Za-z0-9_-]+", "-", label).strip("-")[:100] or "branch"
    return "branches/" + slug + "-" + hashlib.sha256(label.encode()).hexdigest()[:10]


def timestamp(value):
    try:
        return dt.datetime.fromisoformat(value.replace("Z", "+00:00")).timestamp()
    except (ValueError, AttributeError):
        return None


def duration(start, end):
    start, end = timestamp(start), timestamp(end)
    return max(0, end - start) if start is not None and end is not None else None


def elapsed(seconds):
    if seconds is None:
        return "—"
    seconds = int(seconds)
    return f"{seconds // 3600}h {seconds % 3600 // 60}m" if seconds >= 3600 else f"{seconds // 60}m {seconds % 60}s"


STYLE = """
:root{color-scheme:light dark;--bg:#f7f8fa;--panel:#fff;--fg:#182336;--muted:#627084;--line:#dce2eb;--accent:#285bea}
@media(prefers-color-scheme:dark){:root{--bg:#10151e;--panel:#19212e;--fg:#e5edf8;--muted:#9aaac0;--line:#303c50;--accent:#88acff}}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--fg);font:15px/1.5 system-ui,sans-serif}main{max-width:1300px;margin:0 auto;padding:36px 24px}a{color:var(--accent);text-decoration:none}a:hover{text-decoration:underline}h1{font-size:30px;letter-spacing:-.04em;margin:12px 0}h2{font-size:20px;margin:32px 0 12px}p,.muted{color:var(--muted)}nav{display:flex;gap:16px;flex-wrap:wrap}.panel{background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:20px;margin:16px 0;overflow:auto}input{font:inherit;width:min(100%,600px);padding:10px 14px;border:1px solid var(--line);border-radius:8px;background:var(--panel);color:var(--fg)}table{border-collapse:collapse;width:100%;text-align:left}th{color:var(--muted);font-size:12px;text-transform:uppercase;letter-spacing:.04em}td,th{padding:12px 14px;border-bottom:1px solid var(--line);vertical-align:top}tr:last-child td{border-bottom:0}.badge{font:600 12px system-ui;border-radius:20px;padding:4px 9px;white-space:nowrap;background:#6a778226;color:var(--muted)}.success{background:#16966a24;color:#14916c}.failure,.failed,.error,.timed_out{background:#df494924;color:#d95353}.cancelled,.skipped{background:#b3862924;color:#a88333}code{font:12px ui-monospace,monospace}.facts{display:flex;gap:24px;flex-wrap:wrap}.facts strong{font-size:24px;display:block;color:var(--fg)}summary{cursor:pointer;display:flex;gap:12px;align-items:center;flex-wrap:wrap}details{border-top:1px solid var(--line);padding:12px 0}.timeline{min-width:500px}.track{height:12px;background:var(--line);border-radius:4px;overflow:hidden;min-width:180px}.bar{height:100%;background:var(--accent);border-radius:4px}.step-name{max-width:450px}.notice{border-left:3px solid #b38629;padding-left:12px}footer{font-size:12px;color:var(--muted);margin-top:32px}@media(max-width:700px){main{padding:20px 12px}td,th{padding:9px 8px}.panel{padding:12px}h1{font-size:25px}}
 .matrix{min-width:850px}.matrix-axis,.matrix-row{display:grid;grid-template-columns:minmax(260px,1.15fr) minmax(400px,2fr) 72px;gap:12px;align-items:center}.matrix-axis{font-size:11px;color:var(--muted);padding:0 8px 24px}.matrix-ticks{position:relative;height:10px}.matrix-ticks span{position:absolute;white-space:nowrap;transform:translateX(-50%)}.matrix-ticks span:first-child{transform:none}.matrix-ticks span:last-child{transform:translateX(-100%)}.matrix-row{width:100%;border:0;border-top:1px solid var(--line);background:none;color:inherit;font:inherit;text-align:left;padding:7px 8px;cursor:pointer}.matrix-row:hover,.matrix-row:focus-visible{background:var(--line);outline:2px solid var(--accent);outline-offset:-2px}.matrix-label{font-size:12px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}.matrix-duration{font-size:12px;color:var(--muted);text-align:right;white-space:nowrap}.matrix-track{display:block;position:relative;height:18px;background:repeating-linear-gradient(to right,transparent 0,transparent calc(25% - 1px),var(--line) calc(25% - 1px),var(--line) 25%);border-left:1px solid var(--line)}.matrix-span{position:absolute;top:2px;height:14px;border-radius:2px}.phase-job{background:var(--line)}.phase-checkout{background:#ab7ae0}.phase-setup{background:#5a95ee}.phase-build{background:#25a583}.phase-upload{background:#d8a145}.phase-other{background:#8493a8}.legend{display:flex;flex-wrap:wrap;gap:16px;margin:16px 0;font-size:12px;color:var(--muted)}.legend span{display:inline-flex;align-items:center;gap:6px}.legend i{display:inline-block;width:10px;height:10px;border-radius:2px}.job-details:target{outline:2px solid var(--accent)}
"""
FILTER = """const search=document.querySelector('#search');if(search){search.addEventListener('input',()=>{const q=search.value.toLowerCase();document.querySelectorAll('tbody[data-filter] tr').forEach(row=>{row.hidden=!row.textContent.toLowerCase().includes(q)})})}document.querySelectorAll('button[data-job]').forEach(button=>{const detail=document.getElementById(button.dataset.job);if(!detail)return;button.addEventListener('click',()=>{detail.open=!detail.open;if(detail.open)detail.scrollIntoView({block:'nearest'})});detail.addEventListener('toggle',()=>{button.setAttribute('aria-expanded',String(detail.open))})})"""


def page(title, body, root="./"):
    digest = base64.b64encode(hashlib.sha256(FILTER.encode()).digest()).decode()
    policy = f"default-src 'none'; img-src data:; style-src 'unsafe-inline'; script-src 'sha256-{digest}'; base-uri 'none'; form-action 'none'"
    return (
        '<!doctype html><html lang="en"><head><meta charset="utf-8"><link rel="icon" href="data:,">'
        '<meta name="viewport" content="width=device-width,initial-scale=1">'
        f'<meta http-equiv="Content-Security-Policy" content="{escape(policy)}">'
        f'<title>{escape(title)} · nix-overlays builds</title><style>{STYLE}</style></head><body><main>'
        f'<nav><a href="{escape(root)}">nix-overlays / builds</a><a href="https://github.com/nix-ocaml/nix-overlays/actions/workflows/pipeline.yml">GitHub Actions</a></nav>'
        f'<h1>{escape(title)}</h1>{body}'
        '<footer>Reports are indexed by the source commit reported by GitHub. Package explorers also retain the evaluated checkout SHA, which may be a PR merge commit. Raw logs remain in the Actions artifacts.</footer>'
        f'</main><script>{FILTER}</script></body></html>\n'
    )


def badge(status):
    status = str(status or "unknown")
    category = status if status in {"success", "failure", "failed", "error", "timed_out", "cancelled", "skipped"} else "unknown"
    return f'<span class="badge {category}">{escape(status)}</span>'


def write_page(site, path, title, body):
    destination = site / path / "index.html"
    destination.parent.mkdir(parents=True, exist_ok=True)
    root = "../" * len(PurePosixPath(path).parts) if path else "./"
    destination.write_text(page(title, body, root))


def report_counts(snapshot):
    counts = collections.Counter()
    for job in snapshot.get("jobs", []):
        if isinstance(job, dict):
            state = job.get("state")
            counts[state if state in ("built", "cached", "failed", "blocked", "cancelled", "submitted", "queued") else "unknown"] += 1
    return dict(counts)


def render_artifact(api, artifact, run, renderer, site):
    identifier = positive(artifact["id"])
    report = {"id": identifier, "name": artifact["name"], "counts": {}, "status": "unavailable"}
    destination = site / run_path(run) / "jobs" / str(identifier)
    destination.mkdir(parents=True, exist_ok=True)
    try:
        if artifact.get("expired"):
            raise ValueError("the Actions artifact has expired")
        if artifact["size_in_bytes"] > MAX_ARTIFACT_BYTES:
            raise ValueError("the Actions artifact exceeds the download limit")
        data = api.request(f"actions/artifacts/{identifier}/zip", binary=True, limit=MAX_ARTIFACT_BYTES)
        snapshot, events, notes = artifact_data(data)
        if notes:
            warnings = snapshot.get("warnings")
            snapshot["warnings"] = (warnings if isinstance(warnings, list) else []) + notes
            report["note"] = " ".join(notes)
        context = snapshot.get("context")
        if not isinstance(context, dict):
            context = {}
            snapshot["context"] = context
        context["artifactUrl"] = f"https://github.com/{api.repository}/actions/runs/{run['id']}/artifacts/{identifier}"
        context["logsAvailable"] = False
        context["runUrl"] = f"https://github.com/{api.repository}/actions/runs/{run['id']}"
        context["runAttempt"] = str(run["attempt"])
        with tempfile.TemporaryDirectory(prefix="nix-build-report-") as directory:
            directory = Path(directory)
            (directory / "results.json").write_text(json.dumps(snapshot, allow_nan=False))
            (directory / "events.jsonl").write_text("".join(json.dumps(event, allow_nan=False) + "\n" for event in events))
            environment = {k: v for k, v in os.environ.items() if k not in {"GH_TOKEN", "GITHUB_TOKEN"}}
            rendered = subprocess.run(
                [str(renderer), "--render-report", str(directory)],
                stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, env=environment, timeout=90,
            )
            if rendered.returncode:
                raise ValueError("the trusted renderer could not render this report")
            output = directory / "report.html"
            if output.is_symlink() or not output.is_file() or output.stat().st_size > MAX_REPORT_BYTES:
                raise ValueError("the rendered report exceeds the size limit or is missing")
            shutil.copyfile(output, destination / "index.html")
        report.update(status=str(snapshot.get("status", "unknown"))[:80], counts=report_counts(snapshot),
                      flake=str(context.get("flake", ""))[:1000], gitSha=str(context.get("gitSha", ""))[:80])
    except (ValueError, OSError, subprocess.TimeoutExpired, zipfile.BadZipFile) as error:
        report["error"] = str(error)[:500]
        (destination / "index.html").write_text(page(
            "Report unavailable", f'<p>{escape(report["error"])}</p><p><a href="../../">Back to the run</a></p>', "../../../../../"
        ))
    return report


def load_run(api, run_id, attempt):
    data = api.request(f"actions/runs/{positive(run_id)}/attempts/{positive(attempt)}")
    if data.get("path") != ".github/workflows/pipeline.yml" or data.get("repository", {}).get("full_name") != api.repository:
        raise ValueError("the selected run is not this repository's Pipeline")
    if data.get("status") != "completed" or data.get("run_attempt") != attempt:
        raise ValueError("the selected run attempt has not completed")
    if not SHA.fullmatch(data["head_sha"]):
        raise ValueError("invalid source commit")
    pulls = [positive(pr["number"]) for pr in data.get("pull_requests", [])]
    # GitHub omits pull_requests for some fork workflows. Resolve from the
    # authoritative commit API, never from artifact-supplied PR numbers.
    if not pulls and data.get("event") == "pull_request":
        related = api.pages(f"commits/{data['head_sha']}/pulls", None)
        pulls = [positive(pr["number"]) for pr in related if pr.get("base", {}).get("repo", {}).get("full_name") == api.repository]
    run = {
        "id": positive(run_id), "attempt": positive(attempt), "number": data["run_number"],
        "headSha": data["head_sha"], "headBranch": data.get("head_branch") or "detached",
        "headRepository": (data.get("head_repository") or {}).get("full_name") or api.repository,
        "pullRequests": sorted(set(pulls)), "event": data.get("event"),
        "conclusion": data.get("conclusion"), "startedAt": data.get("run_started_at") or data["created_at"],
        "updatedAt": data["updated_at"], "reports": [],
    }
    jobs = api.pages(f"actions/runs/{run_id}/attempts/{attempt}/jobs", "jobs")
    run["jobs"] = [{key: job.get(key) for key in ("id", "name", "status", "conclusion", "started_at", "completed_at", "steps")} for job in jobs]
    return run


def run_rows(runs, prefix=""):
    rows = []
    for run in runs:
        prs = ", ".join(f'PR #{pr}' for pr in run["pullRequests"])
        rows.append(
            f'<tr><td><a href="{prefix}{run_path(run)}/">Run #{escape(run["number"])} · attempt {run["attempt"]}</a>'
            f'<div class="muted">{escape(run["startedAt"])}</div></td><td>{badge(run["conclusion"])}</td>'
            f'<td>{escape(run["headBranch"])}<div class="muted">{escape(prs or run["event"])}</div></td>'
            f'<td><code>{run["headSha"][:12]}</code></td><td>{len(run["reports"])} reports</td></tr>'
        )
    return '<div class="panel"><table><thead><tr><th>Run</th><th>Result</th><th>Branch / PR</th><th>Commit</th><th>Matrix</th></tr></thead><tbody data-filter>' + "".join(rows) + '</tbody></table></div>'


def step_phase(name):
    name = str(name).lower()
    if name.startswith("post "):
        return "other"
    if "checkout" in name:
        return "checkout"
    if "upload" in name:
        return "upload"
    if "build" in name and "report" not in name:
        return "build"
    if any(word in name for word in ("setup", "set up", "install", "nix-s3", "configure")):
        return "setup"
    return "other"


def timeline(run, repository):
    starts = [timestamp(job["started_at"]) for job in run["jobs"]]
    ends = [timestamp(job["completed_at"]) for job in run["jobs"]]
    starts.append(timestamp(run["startedAt"]))
    starts, ends = [x for x in starts if x is not None], [x for x in ends if x is not None]
    origin = min(starts, default=0)
    span = max(max(ends, default=origin) - origin, 1)
    blocks, rows = [], []

    def segment(start, end, phase, label):
        start, end = timestamp(start), timestamp(end)
        if start is None or end is None or end <= start:
            return ""
        offset = max(0, min(100, 100 * (start - origin) / span))
        width = max(0, min(100 - offset, 100 * (end - start) / span))
        return f'<span class="matrix-span phase-{phase}" style="left:{offset:.3f}%;width:{width:.3f}%" title="{escape(label)}"></span>'

    for job in run["jobs"]:
        seconds = duration(job["started_at"], job["completed_at"])
        identifier = f'job-{positive(job["id"])}'
        steps, spans = [], [segment(job["started_at"], job["completed_at"], "job", job["name"])]
        for step in job.get("steps") or []:
            step_time = duration(step.get("started_at"), step.get("completed_at"))
            name = step.get("name", "Step")
            steps.append(f'<tr><td class="step-name">{escape(name)}</td><td>{badge(step.get("conclusion"))}</td><td>{elapsed(step_time)}</td></tr>')
            spans.append(segment(step.get("started_at"), step.get("completed_at"), step_phase(name), f'{name} · {elapsed(step_time)}'))
        rows.append(
            f'<button class="matrix-row" data-job="{identifier}" aria-controls="{identifier}" aria-expanded="false" title="{escape(job["name"])} · {escape(job["conclusion"] or "unknown")}">'
            f'<span class="matrix-label">{escape(job["name"])}</span><span class="matrix-track" aria-hidden="true">{"".join(spans)}</span>'
            f'<span class="matrix-duration">{elapsed(seconds)}</span></button>'
        )
        link = f'https://github.com/{repository}/actions/runs/{run["id"]}/job/{positive(job["id"])}'
        blocks.append(
            f'<details class="job-details" id="{identifier}"><summary>{badge(job["conclusion"])}<strong>{escape(job["name"])}</strong><span class="muted">{elapsed(seconds)}</span></summary>'
            f'<p><a href="{link}">Open Actions job</a></p><div class="timeline">'
            '<table><thead><tr><th>Step</th><th>Result</th><th>Duration</th></tr></thead><tbody>' + "".join(steps) + '</tbody></table></div></details>'
        )
    ticks = ''.join(f'<span style="left:{number * 25}%">{elapsed(span * number / 4)}</span>' for number in range(5))
    legend = ''.join(f'<span><i class="phase-{phase}"></i>{label}</span>' for phase, label in (("checkout", "Checkout"), ("setup", "Setup"), ("build", "Build"), ("upload", "Upload"), ("other", "Other")))
    chart = f'<div class="matrix"><div class="matrix-axis"><span>Elapsed from run start</span><span class="matrix-ticks">{ticks}</span><span>Duration</span></div>' + ''.join(rows) + '</div>'
    return (
        '<h2>Pipeline timeline</h2><p>All Actions jobs share the same time axis. Select a row to expand its step details. '
        'The build step includes tool bootstrap; package activity timelines are inside each report.</p>'
        f'<div class="legend">{legend}</div><div class="panel">{chart}</div><h2>Actions step details</h2><div class="panel">' + "".join(blocks) + '</div>'
    )


def render_indexes(site, catalog):
    runs, repository = catalog["runs"], catalog["repository"]
    # Aliases are rebuilt from the retained catalog, so pruning cannot leave
    # links pointing at deleted runs or let an older run overwrite a newer alias.
    for name in ("branches", "pulls", "commits"):
        shutil.rmtree(site / name, ignore_errors=True)
    groups = collections.defaultdict(list)
    for run in runs:
        groups["commits/" + run["headSha"]].append(run)
        groups[branch_path(run)].append(run)
        groups[f'runs/{run["id"]}'].append(run)
        for pr in run["pullRequests"]:
            groups[f"pulls/{positive(pr)}"].append(run)
        path = run_path(run)
        navigation = (
            f'<a href="../../../{branch_path(run)}/">Branch: {escape(run["headBranch"])}</a>'
            f'<a href="../../../commits/{run["headSha"]}/">Commit: {run["headSha"][:12]}</a>'
            + "".join(f'<a href="../../../pulls/{pr}/">PR #{pr}</a>' for pr in run["pullRequests"])
            + f'<a href="https://github.com/{repository}/actions/runs/{run["id"]}/attempts/{run["attempt"]}">Actions run</a>'
        )
        aggregate = collections.Counter()
        rows = []
        for report in run["reports"]:
            aggregate.update(report["counts"])
            count = report["counts"]
            label = report.get("flake") or report["name"].removeprefix("nix-ci-build-").rsplit("-attempt-", 1)[0]
            rows.append(
                f'<tr><td><a href="jobs/{report["id"]}/">{escape(label)}</a>'
                + (f'<div class="muted">{escape(report["error"])}</div>' if report.get("error") else "")
                + (f'<div class="muted">{escape(report["note"])}</div>' if report.get("note") else "")
                + f'</td><td>{badge(report["status"])}</td><td>{count.get("built", 0)}</td><td>{count.get("cached", 0)}</td><td>{count.get("failed", 0) + count.get("blocked", 0)}</td>'
                f'<td><a href="https://github.com/{repository}/actions/runs/{run["id"]}/artifacts/{report["id"]}">Raw artifact</a></td></tr>'
            )
        facts = ''.join(f'<div><strong>{aggregate.get(key, 0):,}</strong>{label}</div>' for key, label in (("built", "Built roots"), ("cached", "Cached roots"), ("failed", "Failed roots"), ("blocked", "Blocked roots")))
        no_reports = '<p class="notice">No package reports were uploaded for this attempt. Check the Actions jobs below for setup failures or cancellation.</p>' if not rows else ""
        body = f'<nav>{navigation}</nav><p>{badge(run["conclusion"])} · {escape(run["startedAt"])} · {escape(run["headRepository"])}</p><div class="panel facts">{facts}</div>{no_reports}'
        body += "".join(f'<p class="notice">{escape(note)}</p>' for note in run.get("notes", []))
        body += '<h2>Package matrix</h2><label>Filter reports <input id="search" type="search" placeholder="Compiler, platform or target"></label><div class="panel"><table><thead><tr><th>Target</th><th>Result</th><th>Built</th><th>Cached</th><th>Failed / blocked</th><th>Logs</th></tr></thead><tbody data-filter>' + "".join(rows) + '</tbody></table></div>'
        body += timeline(run, repository)
        write_page(site, path, f'Run #{run["number"]} · attempt {run["attempt"]}', body)
    for path, selected in groups.items():
        first = selected[0]
        if path.startswith("branches/"):
            title = first["headRepository"] + " · " + first["headBranch"]
        elif path.startswith("commits/"):
            title = "Commit " + first["headSha"]
        elif path.startswith("pulls/"):
            title = "Pull request #" + path.split("/")[-1]
        else:
            title = "Run #" + str(first["number"]) + " · attempts"
        prefix = "../" * len(PurePosixPath(path).parts)
        write_page(site, path, title, run_rows(selected, prefix))
    body = '<p>Package builds across OCaml compilers, platforms and cross targets. Select a run to explore the matrix and package activity timelines.</p><label>Find a run <input id="search" type="search" placeholder="PR number, branch or commit"></label>'
    body += run_rows(runs)
    body += '<p>The archive retains up to 20 recent attempts within a 400 MiB budget. Older reports remain downloadable from Actions while their artifacts are retained.</p>'
    write_page(site, "", "Build explorer", body)
    (site / ".nojekyll").touch()
    (site / "catalog.json").write_text(json.dumps(catalog, indent=2, allow_nan=False) + "\n")


def tree_size(directory):
    return sum(path.stat().st_size for path in directory.rglob("*") if path.is_file())


def prune(site, catalog, max_runs, max_bytes, keep=None):
    catalog["runs"].sort(key=lambda run: (run["startedAt"], run["id"], run["attempt"]), reverse=True)
    while len(catalog["runs"]) > max_runs or (len(catalog["runs"]) > 1 and tree_size(site) > max_bytes):
        index = next((index for index in range(len(catalog["runs"]) - 1, -1, -1)
                      if (catalog["runs"][index]["id"], catalog["runs"][index]["attempt"]) != keep), None)
        if index is None:
            raise ValueError("the selected attempt exceeds the site budget")
        old = catalog["runs"].pop(index)
        shutil.rmtree(site / run_path(old), ignore_errors=True)
        parent = site / "runs" / str(old["id"])
        if not any(run["id"] == old["id"] for run in catalog["runs"]):
            shutil.rmtree(parent, ignore_errors=True)
    if tree_size(site) > max_bytes:
        raise ValueError("the latest attempt exceeds the site budget")


def catch_up(target, recent, known):
    candidates = [target]
    inspected = 0
    for run in recent:
        latest = run["run_attempt"] - (run["status"] != "completed")
        if latest > 0:
            for number in range(latest, 0, -1):
                inspected += 1
                key = (positive(run["id"]), number)
                if key not in known and key not in candidates:
                    candidates.append(key)
                if len(candidates) >= 5 or inspected >= 100:
                    return candidates
    return candidates


def build(args):
    api = GitHub(args.repository)
    site = Path(args.output)
    if site.exists() and any(site.iterdir()):
        raise ValueError("output directory must be empty")
    site.mkdir(parents=True, exist_ok=True)
    catalog, archive_sha = restore_archive(api, site)
    target = api.request(f"actions/runs/{positive(args.run_id)}")
    attempt = positive(args.attempt or target["run_attempt"])
    selected = (positive(args.run_id), attempt)
    candidates = [selected]
    known = {(run["id"], run["attempt"]) for run in catalog["runs"]}
    published = [tuple(key) for key in catalog.get("publishedAttempts", sorted(known))]
    previous = next((run for run in catalog["runs"] if (run["id"], run["attempt"]) == selected), None)
    if args.refresh and previous:
        catalog["runs"].remove(previous)
        known.remove(selected)
    # Actions concurrency can replace a pending publisher. Catch up completed
    # attempts on subsequent runs instead of relying on an unbounded queue.
    recent = api.request("actions/workflows/pipeline.yml/runs?per_page=20")["workflow_runs"]
    candidates = catch_up(selected, recent, known | set(published))
    for run_id, number in candidates[:5]:
        if (run_id, number) in known:
            continue
        run = load_run(api, run_id, number)
        artifacts = api.pages(f"actions/runs/{run_id}/artifacts", "artifacts")
        old_reports = {report["id"]: report for report in previous["reports"]} if previous and (run_id, number) == selected else {}
        matches = []
        for artifact in artifacts:
            match = ARTIFACT_NAME.fullmatch(artifact["name"])
            if match and int(match[1]) == number:
                matches.append(artifact)
        if len(matches) > 80:
            run["notes"] = ["Only the first 80 report artifacts are shown; this attempt exceeds the publisher's artifact limit."]
        for artifact in sorted(matches, key=lambda item: item["id"])[:80]:
            old = old_reports.pop(artifact["id"], None)
            if artifact.get("expired") and old and old["status"] != "unavailable":
                run["reports"].append(old)
            else:
                run["reports"].append(render_artifact(api, artifact, run, args.renderer, site))
        run["reports"].extend(old_reports.values())
        run["reports"].sort(key=lambda report: report["name"])
        catalog["runs"].append(run)
        known.add((run_id, number))
        published.append((run_id, number))
    catalog["publishedAttempts"] = list(dict.fromkeys(published))[-1000:]
    for name in ("branches", "pulls", "commits"):
        shutil.rmtree(site / name, ignore_errors=True)
    prune(site, catalog, args.max_runs, args.max_bytes, keep=selected)
    while True:
        render_indexes(site, catalog)
        if tree_size(site) <= args.max_bytes:
            break
        prune(site, catalog, len(catalog["runs"]) - 1, args.max_bytes, keep=selected)
    if os.environ.get("GITHUB_OUTPUT"):
        with open(os.environ["GITHUB_OUTPUT"], "a") as output:
            output.write(f"archive_sha={archive_sha}\n")
    print(f"Prepared {len(catalog['runs'])} run attempts ({tree_size(site) // (1024 * 1024)} MiB)")


def archive_site(args):
    repository = GitHub(args.repository).repository
    if args.expected_sha and not SHA.fullmatch(args.expected_sha):
        raise ValueError("invalid previous archive SHA")
    source = Path(args.directory).resolve()
    if not (source / "catalog.json").is_file() or tree_size(source) > MAX_ARCHIVE_BYTES:
        raise ValueError("invalid generated site")
    with tempfile.TemporaryDirectory(prefix="nix-report-archive-") as temporary:
        directory = Path(temporary)
        shutil.copytree(source, directory, dirs_exist_ok=True)
        def git(*arguments):
            subprocess.run(["git", *arguments], cwd=directory, check=True, stdout=subprocess.DEVNULL)
        git("init", "--quiet", "--initial-branch=" + ARCHIVE_BRANCH)
        git("config", "user.name", "github-actions[bot]")
        git("config", "user.email", "41898282+github-actions[bot]@users.noreply.github.com")
        git("add", ".")
        git("commit", "--quiet", "-m", "Update generated build reports")
        git("remote", "add", "origin", "https://github.com/" + repository + ".git")
        # This branch is generated storage, deliberately a single snapshot.
        # The lease prevents overwriting an unexpected concurrent/manual update.
        git("push", "--force-with-lease=refs/heads/" + ARCHIVE_BRANCH + ":" + args.expected_sha,
            "origin", "HEAD:refs/heads/" + ARCHIVE_BRANCH)


def check_pages(args):
    config = GitHub(args.repository).request("pages", missing=True)
    enabled = config is not None and config.get("build_type") == "workflow"
    if os.environ.get("GITHUB_OUTPUT"):
        with open(os.environ["GITHUB_OUTPUT"], "a") as output:
            output.write(f"enabled={'true' if enabled else 'false'}\n")
    print("GitHub Pages is ready" if enabled else "Report publishing is skipped: select GitHub Actions in Settings > Pages to enable it.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    prepare = commands.add_parser("build")
    prepare.add_argument("--repository", required=True)
    prepare.add_argument("--run-id", type=positive, required=True)
    prepare.add_argument("--attempt", type=positive)
    prepare.add_argument("--renderer", type=Path, required=True)
    prepare.add_argument("--output", required=True)
    prepare.add_argument("--max-runs", type=positive, default=20)
    prepare.add_argument("--max-bytes", type=positive, default=400 * 1024 * 1024)
    prepare.add_argument("--refresh", action="store_true", help="regenerate the selected attempt, retaining existing pages if its artifacts expired")
    save = commands.add_parser("archive")
    save.add_argument("--repository", required=True)
    save.add_argument("--directory", required=True)
    save.add_argument("--expected-sha", default="")
    check = commands.add_parser("check-pages")
    check.add_argument("--repository", required=True)
    args = parser.parse_args()
    {"build": build, "archive": archive_site, "check-pages": check_pages}[args.command](args)


if __name__ == "__main__":
    main()
