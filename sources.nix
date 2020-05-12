args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-05-12";
  url = https://github.com/nixos/nixpkgs/archive/683c68232e91f76386db979c461d8fbe2a018782.tar.gz;
  sha256 = "1fn7q540bk7nhvf6pnlljgfk51qwh2xpvvz30a1d4sd0l7z64mvc";
}) (args // { inherit overlays; })
