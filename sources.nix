args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-08-20";
  url = https://github.com/nixos/nixpkgs/archive/bd0e645f02416acb1683e458b4ed3ef4f9b09da9.tar.gz;
  sha256 = "0wccl5fizqh5k62vx7ylr98d9k5aa8iwhjj015f9svfffkclsznr";
}) (args // { inherit overlays; })

