args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-07-10";
  url = https://github.com/nixos/nixpkgs/archive/8d05772134f17180fb2711d0660702dae2a67313.tar.gz;
  sha256 = "0pnyg26c1yhnp3ymzglc71pd9j0567ymqy6il5ywc82bbm1zy25a";
}) (args // { inherit overlays; })

