args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-06-03";
    url = https://github.com/nixos/nixpkgs/archive/1c2986bbb806.tar.gz;
    sha256 = "0y1275nzlmsys5rk7ivzbdc8cpjs9cbk0wz6yh3i2c57b8nbd3ym";
  })
  (args // { inherit overlays; })
