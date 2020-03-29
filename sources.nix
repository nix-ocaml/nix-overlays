args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-03-28";
  url = https://github.com/nixos/nixpkgs/archive/ae6bdcc53584aaf20211ce1814bea97ece08a248.tar.gz;
  sha256 = "0hjhznns1cxgl3hww2d5si6vhy36pnm53hms9h338v6r633dcy77";
}) (args // { inherit overlays; })
