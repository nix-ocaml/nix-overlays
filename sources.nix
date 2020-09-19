args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-09-13";
  url = https://github.com/nixos/nixpkgs/archive/441a7da8080352881bb52f85e910d8855e83fc55.tar.gz;
  sha256 = "0093drxn7blw4hay41zbqzz1vhldil5sa5p0mwaqy5dn08yn4y3q";
}) (args // { inherit overlays; })

