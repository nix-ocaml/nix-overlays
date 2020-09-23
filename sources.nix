args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-09-22";
  url = https://github.com/nixos/nixpkgs/archive/1179840f9a88b8a548f4b11d1a03aa25a790c379.tar.gz;
  sha256 = "00jy37wj04bvh299xgal2iik2my9l0nq6cw50r1b2kdfrji8d563";
}) (args // { inherit overlays; })

