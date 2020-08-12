args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-08-11";
  url = https://github.com/nixos/nixpkgs/archive/32b46dd897ab2143a609988a04d87452f0bbef59.tar.gz;
  sha256 = "1gzfrpjnr1bz9zljsyg3a4zrhk8r927sz761mrgcg56dwinkhpjk";
}) (args // { inherit overlays; })

