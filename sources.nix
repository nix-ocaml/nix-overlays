args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2021-01-21";
  url = https://github.com/nixos/nixpkgs/archive/f217c0ea7c148ddc0103347051555c7c252dcafb.tar.gz;
  sha256 = "0cyksxg2lnzxd0pss09rmmk2c2axz0lf9wvgvfng59nwf8dpq2kf";
}) (args // { inherit overlays; })

