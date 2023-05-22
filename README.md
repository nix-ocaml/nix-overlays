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
      (import "${nixpkgs-sources}/overlay" custom-nixpkgs)
    ];
  };
in

pkgs
```

## License

Copyright (c) 2023 António Nuno Monteiro.

See the [`MIT License`](./LICENSE) text.

Note: MIT license does not apply to the packages built by nix-overlays, merely
to the files in this repository (the Nix expressions, build scripts, NixOS
modules, etc.). It also might not apply to patches included in the repository,
which may be derivative works of the packages to which they apply. The
aforementioned artifacts are all covered by the licenses of the respective
packages.

