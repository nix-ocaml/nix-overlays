# Shared prerequisite pilot

The [pilot workflow](../../.github/workflows/shared-prerequisite-pilot.yml)
contains one reusable-workflow call. [build.json](build.json) supplies all four
package sets, runner labels, read/write caches, and the pilot's work limits.
The [reusable workflow](https://github.com/nix-ocaml/nix-ci-build/pull/17) handles planning, the two dynamic matrices, signed builder
reuse, plan transfer, failure handling, and combined reports. Adding a set does
not require another workflow job.

The caller maps the existing `R2_SIGNING_KEY`, `R2_ACCESS_KEY_ID`, and
`R2_SECRET_ACESS_KEY` secrets once. Only same-repository PRs can run it; manual
runs become available when the workflow reaches the default branch. The
production `pipeline.yml` and `ci.sh` remain separate, with no new root flake
inputs.

## Bounded real package sets

Each set selects the real `lwt` derivation from one x86_64-linux scope:

| Set | Scope under `legacyPackages.x86_64-linux` |
| --- | --- |
| `native-5_5` | `ocaml-ng.ocamlPackages_5_5` |
| `native-5_6` | `ocaml-ng.ocamlPackages_5_6` |
| `musl-5_5` | `pkgsCross.musl64.ocaml-ng.ocamlPackages_5_5` |
| `musl-5_6` | `pkgsCross.musl64.ocaml-ng.ocamlPackages_5_6` |

The limits allow only these four roots and their two reviewed `libev`
derivations. The native helper is shared across OCaml versions, as is the
separate musl helper. Those helper paths come from Lwt's actual input graph;
the global musl `libev` attribute is a different derivation. If their identities
change, update the two exact paths after reviewing the new graph. The guard
fails closed instead of authorizing new dependencies.

At most six derivations may build. Every remaining prerequisite must have a
complete cached closure, whose union is limited to 2 GiB of uncompressed NAR
content. This is a distinct-content limit, not a total network-traffic budget:
multiple runners can download the same dependency, and builder bootstrap and
recipe artifacts are separate. Each worker has a 20-minute timeout.

The workflow builds the tool once per host system and transfers its signed
closure to workers. Workers import the saved derivation plan without evaluating
the package sets again. A producer must publish its outputs successfully before
consumers can use them. Normal Nix signature verification remains enabled.

All four roots were cached in the initial pilot. Both worker matrices skipped
correctly and the combined report recorded no builds. That validates the warm
path, not a native/musl speedup. A completely cold four-scope plan currently has
about 2.61 GiB of prerequisite NAR content, so the 2 GiB guard intentionally
refuses it. The smaller controlled musl comparison below fits the budget.

The reusable workflow retains the portable plan, guard evidence, builder
bootstrap timings, worker reports and logs, and a combined HTML/JSON report.
Per-derivation build activity is elapsed build time, not CPU time; worker wall
time and bootstrap cost should be assessed separately.

## Nonempty workflow smoke

[shared-prerequisite-smoke.yml](../../.github/workflows/shared-prerequisite-smoke.yml)
calls the same reusable workflow with [smoke.json](smoke.json). Its no-input
[fixture flake](fixture/flake.nix) contains two tiny roots consuming different
outputs of one shared derivation. The initial cold run should build exactly
three derivations through one prerequisite job and two package jobs, publishing
them to the existing signed R2 cache. A rerun should find them cached and skip
both matrices. It does not delete cache entries or force invalidation.

Only this fixture uses `/bin/sh` with `sandbox = false`; its script uses shell
builtins and has no external dependency closure. The smoke configuration allows
only the three fixture derivations and at most 1 MiB of cached prerequisites.
Signature verification and signed publication are unchanged. The real-package
configuration does not disable sandboxing. This test checks workflow execution,
not package-build performance.

## Controlled musl comparison

[shared-prerequisite-comparison.yml](../../.github/workflows/shared-prerequisite-comparison.yml)
is a separate manual-only experiment. It builds a pinned nix-ci-build once,
then evaluates an immutable Git-filtered snapshot of the checkout. The harness
compares the two real musl Lwt roots on OCaml 5.5 and 5.6, withholding only those
roots and their exact common compiled libev from a private seed cache.

Cached compilers, tools, libraries, and sources are copied into the seed without
building them. Each worker gets a fresh Linux chroot store. Independent workers
use separate publication caches; coordinated workers share a private publication
cache. Neither case can read the deliberately withheld outputs from upstream,
and no experiment outputs are written to production R2.

The harness checks actual build activity for four builds independently versus
three with coordination, with libev built twice versus once. It rejects work
outside those exact three derivations, requires the whole prerequisite boundary
to be cached, caps its NAR content at 2 GiB, and imposes a 20-minute experiment
deadline within a 30-minute job. Root privileges create disposable chroot stores;
the private caches have their own signature policy.

Artifacts retain both plans, command logs, worker and aggregate reports,
identities, seed sizes, build activity, publication evidence, and worker wall
time. Cache file sizes are not network traffic. Planning, seed preparation, and
tool bootstrap remain separate, and less duplicate work does not by itself
establish a wall-time speedup.
