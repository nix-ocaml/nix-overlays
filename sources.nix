args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2021-01-30";
  url = https://github.com/nixos/nixpkgs/archive/1b6764da4e600e66c896a6746ceaa038a40a8f2b.tar.gz;
  sha256 = "0srpa9nx1xczzn2idg92s7asdz6vwv6x09gmnxkifgcanjwp57z4";
}) (args // { inherit overlays; })

