# OCaml-focused custom nix-overlays

This repo contains a set of custom overlays and upgrades over the upstream
nixpkgs set of (mostly) OCaml packages, and a few other curated derivations.

## Using this set of packages

### With Flakes

In your `flake.nix`:

```nix
{
  # Use this repo as the `nixpkgs` URL
  inputs.nixpkgs = "github:anmonteiro/nix-overlays";


  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs {
        system = "YOUR_SYSTEM_STRING";
      };
    in
    {
      ...
    };
}
```

#### Alternative (advanced)


```nix
{
  # Simply use this repo as the `nixpkgs` URL
  inputs.nixpkgs = "github:nixOS/nixpkgs";

  inputs.ocaml-overlay = "github:anmonteiro/nix-overlays";
  inputs.ocaml-overlay.nixpkgs.follows = "nixpkgs";


  outputs = { self, nixpkgs }:
    let
      system = "YOUR_SYSTEM_STRING";
      pkgs = import nixpkgs {
        overlays = [
          ocaml-overlay.overlays.${system}.default
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
      https://github.com/anmonteiro/nix-overlays/archive/master.tar.gz;
  pkgs = import nixpkgs-sources { };
in

pkgs
```
