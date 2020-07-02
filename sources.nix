args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-06-30";
  url = https://github.com/nixos/nixpkgs/archive/b3251e04ee470c20f81e75d5a6080ba92dc7ed3f.tar.gz;
  sha256 = "0hld390gb3q055sa7j1rzxl1hzaxgagc60vrqmkk8fnfpv813g75";
}) (args // { inherit overlays; })

