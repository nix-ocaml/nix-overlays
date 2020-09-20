args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-09-20";
  url = https://github.com/nixos/nixpkgs/archive/2a35f664394b379e0c0785cc769ff6ccc791be39.tar.gz;
  sha256 = "1ac01hyvniiwrwgqlvmx76dxc7aqg71nx3d05d0dc35lbyjq7acf";
}) (args // { inherit overlays; })

