args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-03-15";
    url = https://github.com/nixos/nixpkgs/archive/e9f42f11e5c4.tar.gz;
    sha256 = "11dnrbdyjmgr5w6b2qx60nk2p0g8v0m3hvwimy9w5dkn5r8m9gx6";
  })
  (args // { inherit overlays; })
