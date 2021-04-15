args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-04-15";
    url = https://github.com/nixos/nixpkgs/archive/ca373323f1dc.tar.gz;
    sha256 = "1bsah6g0kys2qvrslbisg28z7wl7rn9kga3wnpbmj7jp2r1giskd";
  })
  (args // { inherit overlays; })
