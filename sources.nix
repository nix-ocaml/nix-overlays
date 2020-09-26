args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-09-26";
  url = https://github.com/nixos/nixpkgs/archive/daaa0e33505082716beb52efefe3064f0332b521.tar.gz;
  sha256 = "15vprzpbllp9hy5md36ch1llzhxhd44d291kawcslgrzibw51f95";
}) (args // { inherit overlays; })

