args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2021-01-06";
  url = https://github.com/nixos/nixpkgs/archive/877bc4b72019d46941c6c8b801ad95c83152c4c3.tar.gz;
  sha256 = "1ld6yc8z5qc0aiywfv3x39swwvm3yf23gvcsizhqqfvqj12dyd97";
}) (args // { inherit overlays; })

