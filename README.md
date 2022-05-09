# OCaml-focused custom nix-overlays

This repo contains a set of custom overlays and upgrades over the upstream
nixpkgs set of (mostly) OCaml packages, and a few other curated derivations.

## Using this set of packages

### Using Flakes

```nix
{
  # Simply use this repo as the `nixpkgs` URL
  inputs.nixpkgs = "github:anmonteiro/nix-overlays";
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
