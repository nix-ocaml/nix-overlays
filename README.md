# OCaml-focused custom [Nix Overlays](https://nixos.wiki/wiki/Overlays)

This repo contains a set of custom overlays and upgrades over the upstream
nixpkgs set of (mostly) OCaml packages, and a few other curated derivations.

## Using this set of packages

### With Flakes

In your `flake.nix`:

```nix
{
  # Use this repo as the `nixpkgs` URL
  inputs.nixpkgs.url = "github:nix-ocaml/nix-overlays";


  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkg.legacyPackages.${"YOUR_SYSTEM_STRING"};
    in
    {
      ...
    };
}
```

#### Alternative (advanced)

```nix
{
  inputs.nixpkgs.url = "github:nixOS/nixpkgs";

  inputs.ocaml-overlay.url = "github:nix-ocaml/nix-overlays";
  inputs.ocaml-overlay.inputs.nixpkgs.follows = "nixpkgs";


  outputs = { self, nixpkgs, ocaml-overlay }:
    let
      system = "YOUR_SYSTEM_STRING";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          ocaml-overlay.overlays.default
        ];
      };
    in
    {
      ...
    };
}
```

### Without Flakes

```nix
let
  nixpkgs-sources =
    builtins.fetchTarball
      https://github.com/nix-ocaml/nix-overlays/archive/master.tar.gz;
  pkgs = import nixpkgs-sources { };
in

pkgs
```

#### Alternative (advanced)

```nix
let
  nixpkgs-sources =
    builtins.fetchTarball
      https://github.com/nix-ocaml/nix-overlays/archive/master.tar.gz;

  custom-nixpkgs = /path/to/custom/nixpkgs;

  pkgs = import custom-nixpkgs {
    overlays = [
      (import "${nixpkgs-sources}/overlay")
    ];
  };
in

pkgs
```

## Build reports

Each package job uploads an interactive `report.html` alongside `results.json`,
`events.jsonl` and the full logs. Download the Actions artifact and open
`report.html` locally; GitHub's artifact viewer does not run interactive HTML.

After Pipeline completes, the **Build reports** workflow publishes a static
[build explorer](https://nix-ocaml.github.io/nix-overlays/) with the package
matrix, package activity timelines, and Actions job/step durations. Each run
links to its branch, pull request and source commit history. The evaluated
checkout SHA is retained separately because PR builds may evaluate a synthetic
merge commit.

Report URLs include the run attempt and artifact ID:

```text
runs/<run-id>/<attempt>/
runs/<run-id>/<attempt>/jobs/<artifact-id>/
runs/<run-id>/
pulls/<pr-number>/
commits/<head-sha>/
```

Branch pages have stable names derived from both the source repository and
branch, and are linked from each run. Attempt URLs identify a fixed source run;
reruns create separate paths. The archive keeps up to 20 recent attempts within
a 400 MiB budget, always including the selected publication. Older pages are
removed, and history indexes are rebuilt to avoid stale links. Raw artifacts
remain subject to their 14-day Actions
retention and are linked from the hosted explorer.

### Enabling publication

Once this workflow and the report-capable nix-ci-build pin are on `master`,
select **Settings → Pages → Build and deployment → Source: GitHub Actions**.
Allow the `github-pages` environment to deploy from `master`. The publisher
skips cleanly until Pages is configured. If using a custom domain, set the
repository variable `BUILD_REPORTS_URL` to the site's base URL so package-job
summaries link to it.

The publisher runs trusted code and the pinned renderer from the default
branch. It reads only bounded JSON data from the originating run's artifacts,
then regenerates every new package page with `nix-ci-build --render-report`.
Artifact HTML and scripts are never published or executed. Full log files stay
in the downloadable artifact. A separate deployment job holds the Pages and
archive-write permissions; package builds do not receive them.

The generated `build-reports` branch stores the current archive as a single
snapshot commit, replaced with a lease on each successful publication. Do not
edit that branch manually. Publisher runs are serialized; each also catches
up a bounded batch of recent attempts if GitHub replaced a pending publisher.
Use **Actions → Build reports → Run workflow** with a Pipeline run ID and an
optional attempt to recover an omitted run while its artifacts are available.
Manual publication regenerates that attempt with the current trusted renderer;
already published pages are preserved if their artifacts have expired.
`workflow_run` publication starts only after the workflow exists on the default
branch; a PR cannot deploy its own workflow or renderer.

For a local preview using an already built, trusted renderer:

```sh
python3 scripts/report_site.py build \
  --repository nix-ocaml/nix-overlays --run-id <run-id> --attempt <attempt> \
  --renderer /path/to/nix-ci-build --output /tmp/build-reports-preview
python3 -m http.server --directory /tmp/build-reports-preview 8000
```

This reads GitHub through the authenticated `gh` CLI and writes only the preview
directory. Publisher tests run with
`python3 -m unittest discover -s scripts -p test_report_site.py`.

## License

Copyright (c) 2023 António Nuno Monteiro.

See the [`MIT License`](./LICENSE) text.

Note: MIT license does not apply to the packages built by nix-overlays, merely
to the files in this repository (the Nix expressions, build scripts, NixOS
modules, etc.). It also might not apply to patches included in the repository,
which may be derivative works of the packages to which they apply. The
aforementioned artifacts are all covered by the licenses of the respective
packages.
