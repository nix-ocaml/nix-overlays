args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-08-21";
  url = https://github.com/nixos/nixpkgs/archive/c59ea8b8a0e7f927e7291c14ea6cd1bd3a16ff38.tar.gz;
  sha256 = "1ak7jqx94fjhc68xh1lh35kh3w3ndbadprrb762qgvcfb8351x8v";
}) (args // { inherit overlays; })

