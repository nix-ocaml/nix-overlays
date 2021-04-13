args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-04-12";
    url = https://github.com/nixos/nixpkgs/archive/0c896e754d96.tar.gz;
    sha256 = "00naygpjl3mdz9nhv07fbkk6y08qc63zr3i8xnsprrrr53rmmsiv";
  })
  (args // { inherit overlays; })
