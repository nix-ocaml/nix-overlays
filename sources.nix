args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-11-29";
  url = https://github.com/nixos/nixpkgs/archive/11b75530a1fff2ef44c2d6dab55c9fdbfb1263fc.tar.gz;
  sha256 = "15shpr5mmzpzyr6s6n4wzqzv0hx195lyz54qq0n0igysasjzycav";
}) (args // { inherit overlays; })

