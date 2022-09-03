# OCaml-focused custom nix-overlays

This repo contains a set of custom overlays and upgrades over the upstream
nixpkgs set of (mostly) OCaml packages, and a few other curated derivations.

## Using this set of packages

### With Flakes

In your `flake.nix`:

```nix
{
  # Use this repo as the `nixpkgs` URL
  inputs.nixpkgs.url = "github:nix-ocaml/nix-overlays";

  outputs = {
    self,
    nixpkgs,
  }: let
    # Include supported systems e.g ["x86_64-linux" "aarch64-darwin"]
    supportedSystems = [];

    forAllSystems = f:
      nixpkgs.lib.genAttrs supportedSystems
      (system: f system (import nixpkgs {inherit system;}));

    # Change 0_00 to a supported ocamlPackages version e.g 5_00 to get OCaml 5
    ocamlPackagesFor = forAllSystems (system: pkgs: pkgs.ocaml-ng.ocamlPackages_0_00);
  in {
    # Example Usage
    devShell = forAllSystems (
      system: pkgs: let
        ocamlPackages = ocamlPackagesFor.${system};
      in
        pkgs.mkShell {
          nativeBuildInputs = with ocamlPackages; [ocaml];
        }
    );
  };
}
```

#### Alternative (advanced)

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";

    ocaml-overlay = {
      url = "github:nix-ocaml/nix-overlays";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ocaml-overlay,
  }: let
    # Include supported systems e.g ["x86_64-linux" "aarch64-darwin"]
    supportedSystems = [];

    forAllSystems = f:
      nixpkgs.lib.genAttrs supportedSystems
      (system:
        f system (import nixpkgs {
          inherit system;
          overlays = [ocaml-overlay.overlays.${system}.default];
        }));

    # Change 0_00 to a supported ocamlPackages version e.g 5_00 to get OCaml 5
    ocamlPackagesFor = forAllSystems (system: pkgs: pkgs.ocaml-ng.ocamlPackages_0_00);
  in {
    # Example Usage
    devShell = forAllSystems (
      system: pkgs: let
        ocamlPackages = ocamlPackagesFor.${system};
      in
        pkgs.mkShell {
          nativeBuildInputs = with ocamlPackages; [ocaml];
        }
    );
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
      (import "${nixpkgs-sources}/overlay" { nixpkgs = custom-nixpkgs; })
    ];
  };
in

pkgs
```
