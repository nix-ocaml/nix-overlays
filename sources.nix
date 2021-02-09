args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-02-09";
    url = https://github.com/nixos/nixpkgs/archive/8c8731330b53ba0061686f36f10f101e662a4717.tar.gz;
    sha256 = "0ak4d254myq6cl3d7jkq6n0apxabvwjz62zdw9habnrqg8asl8gk";
  })
  (args // { inherit overlays; })
