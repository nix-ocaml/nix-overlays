# OCaml-focused custom [Nix Overlays](https://nixos.wiki/wiki/Overlays)

This repo contains a set of custom overlays and upgrades over the upstream
nixpkgs set of (mostly) OCaml packages, and a few other curated derivations.

## Using this set of packages

### With Flakes

```
nix flake init -t github:nix-ocaml/nix-overlays
```

or

In your `flake.nix`:

```nix
{
  # Use this repo as the `nixpkgs` URL
  inputs = {
    nixpkgs.url = "github:nix-ocaml/nix-overlays";
  };

  outputs = { self, nixpkgs }:
    let
      l = nixpkgs.lib // builtins;
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
      forAllSystems = f: l.genAttrs supportedSystems (system: f system (nixpkgs.legacyPackages.${system})); 

      ocamlVersion = pkgs: pkgs.ocaml-ng.ocamlPackages_5_0;
    in
    {
      packages = 
        forAllSystems (_: pkgs: 
          let 
            ocamlPackages = ocamlVersion pkgs;
          in
          default = ...);
    };
}
```

#### Alternative (flake-parts)

```
nix flake init -t github:nix-ocaml/nix-overlays#flake-parts
```

or

in your `flake.nix`

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    ocaml-overlay = {
      url = "github:nix-ocaml/nix-overlays";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, flake-parts, ocaml-overlay, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch_64-darwin" ];
      perSystem = {inputs', ...}: {
        config = {
          _module.args.pkgs = (inputs'.nixpkgs.legacyPackages).extend ocaml-overlay.overlay;
          packages.default = ...;
        };
     };
  };
}
```

### Without Flakes

```nix
let
  ocaml-overlay =
    builtins.fetchTarball
      https://github.com/nix-ocaml/nix-overlays/archive/master.tar.gz;
  pkgs = import <nixpkgs> { overlays = [ ocaml-overlay.overlay ] };
in
pkgs
```
