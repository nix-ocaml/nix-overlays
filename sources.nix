args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-07-05";
    url = https://github.com/nixos/nixpkgs/archive/20887e4bbfda.tar.gz;
    sha256 = "0hc79sv59appb7bynz5bzyqvrapyjdq63s79i649vxl93504kmnv";
  })
  (args // { inherit overlays; })
