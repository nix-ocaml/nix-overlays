# Shared prerequisite pilot

The [pilot workflow](../../.github/workflows/shared-prerequisite-pilot.yml)
exercises nix-ci-build's shared execution plan against this checkout's real
package sets and the existing signed R2 cache. It is separate from
`pipeline.yml` and `ci.sh`, and adds no flake inputs.

It selects `lwt` from each of these x86_64-linux scopes:

| Set | Scope under `legacyPackages.x86_64-linux` |
| --- | --- |
| `native-5_5` | `ocaml-ng.ocamlPackages_5_5` |
| `native-5_6` | `ocaml-ng.ocamlPackages_5_6` |
| `musl-5_5` | `pkgsCross.musl64.ocaml-ng.ocamlPackages_5_5` |
| `musl-5_6` | `pkgsCross.musl64.ocaml-ng.ocamlPackages_5_6` |

These are the real scopes behind the production package sets. The pilot uses
smaller roots than the usual musl package selection. It preserves package
recipes, compiler options, and derivation identities.

The planner evaluates all four sets, resolves their actual compiled `libev`
dependencies, and allows at most six exact derivations: four Lwt roots and two
libev builds. Each libev derivation is shared across OCaml versions; native and
musl libev remain distinct. A missing compiler, unrelated library, or source fetcher stops the
pilot before workers start. Every remaining dependency must have a complete
closure in the existing read caches. Their union may contain at most 2 GiB of
uncompressed NAR content. That is a bound on distinct dependency content, not
total network traffic: multiple runners may download the same dependency,
and tool bootstrap and recipe artifacts are separate.

The workflow builds the pinned nix-ci-build revision once on x86_64-linux,
exports its signed runtime closure, and transfers that exact closure to the
workers and report job. It reads the evaluator's upstream cache during this
bootstrap. Subsequent package work reads the ordinary overlay and NixOS
caches. Normal Nix signature verification remains enabled throughout.

The shared prerequisite matrix runs before the package matrix. Both matrices
skip cleanly when empty. Workers import the saved derivation bundle without
re-evaluating the source flake, refresh cache availability, and refuse to build
outside their assigned ownership. A producer only succeeds after its outputs
are published to the existing R2 destination. One failed prerequisite does not
prevent unrelated package workers from checking their own dependencies.

Cache setup reuses the existing `R2_SIGNING_KEY`, `R2_ACCESS_KEY_ID`, and
`R2_SECRET_ACESS_KEY` repository secrets through `nix-s3-action`. Only
same-repository PRs can run the pilot. It triggers when the pilot files change;
after the workflow reaches the default branch, it is also available through
**Run workflow**. A same-repository PR also runs the bounded musl comparison
described below; manual runs enable it with the **compare** checkbox. The
ordinary pipeline remains unchanged and may run alongside the pilot.

The artifacts retain:

- The execution plan, package/helper identities, cache checks, and portable
  derivation bundle.
- The exact signed builder closure, with bootstrap timing in the plan.
- Every available worker report, including failed attempts, import timing,
  per-derivation build activity, publication checks, and full logs.
- The combined HTML report, `pilot-measurements.json`, and a concise Actions
  summary with build activity, worker wall span, duplicate builds, and missing
  reports.

Fully cached roots are a successful warm run: both worker matrices are empty,
and the report explicitly records zero observed builds. This validates cache
planning and the empty-stage path; it does **not** establish a native/musl
build speedup. On the initial checked revision, all four Lwt roots were cached.
The exact helper graph records two real cross-version shared libev derivations.
The planner does not treat similarly named native/musl packages as identical.

The natural plan's 2 GiB boundary cap is intentional: a completely cold set of
all four Lwt roots would currently require about 2.61 GiB of distinct cached
prerequisites and would stop. The controlled comparison uses just the two musl
versions, whose cached boundary is about 1.35 GiB.

## Controlled musl comparison

A separate job imports the same signed builder artifact and uses the benchmark
harness from that exact nix-ci-build revision. It evaluates an immutable,
Git-filtered store snapshot of this workflow's checkout, then compares the two real musl Lwt
roots on OCaml 5.5 and 5.6. Only those two roots and their exact common compiled
libev may build: three unique derivations, including every selected output.

It copies cached compilers, tools, libraries, and source archives into a frozen
private seed without building them. The seed excludes the selected Lwt and
libev outputs even when they exist upstream. Each worker uses a fresh Linux
chroot store, so the ordinary store and the builder's dependencies cannot warm
either case. Independent workers receive separate publication caches; the
coordinated workers share one private publication cache. No comparison outputs
are written to production R2, and no production cache entries are deleted.

The expected result is four builds independently versus three with a shared
prerequisite, with libev built twice versus once. The harness verifies these
counts from actual build activity, rejects work outside the exact allowlist,
requires the entire prerequisite boundary to be cached, caps its NAR content
at 2 GiB, and imposes a 20-minute experiment deadline. Root privileges are used
only to create disposable Linux chroot stores. The private experiment caches
use their own signature policy; the signed production-cache jobs keep normal
verification enabled.

The comparison artifacts contain both plans, retained command logs, worker and
aggregate reports, exact identities, measured build activity, worker wall time,
seed sizes, and publication evidence. Cache file sizes are not network traffic,
and summed build activity is not CPU time. Seed preparation, planning, and tool
bootstrap are recorded separately; a reduction in duplicate work does not by
itself establish a wall-time speedup.

For earlier controlled duplicate-work evidence, the separate
[nix-ci-build comparison](https://github.com/nix-ocaml/nix-ci-build/actions/runs/43441414870)
used a frozen cache seed and independent stores: it observed four builds
independently and three with coordination, with native `topkg` built twice
versus once. That small comparison did not show a wall-time speedup. Neither
comparison changes package recipes or runs a baseline against a cache warmed
by its other arm.

Run the bounded-work checks locally with:

```sh
python3 -B ci/shared-pilot/test_pilot.py
```

The package selection and planning steps can be inspected on any host able to
evaluate x86_64-linux derivations. Execution belongs on x86_64-linux. The
workflow limits planning/bootstrap to 30 minutes, each natural worker to
20 minutes, the comparison job to 30 minutes, and aggregation to 10 minutes;
expanding to larger families requires a new,
explicitly reviewed build and cached-dependency budget.
