args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-05-16";
  url = https://github.com/nixos/nixpkgs/archive/b47873026c7e356a340d0e1de7789d4e8428ac66.tar.gz;
  sha256 = "0wlhlmghfdvqqw2k7nyiiz4p9762aqbb2q88p6sswmlv499x5hb3";
}) (args // { inherit overlays; })
