args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-06-03";
  url = https://github.com/nixos/nixpkgs/archive/467ce5a9f45aaf96110b41eb863a56866e1c2c3c.tar.gz;
  sha256 = "0qz7wgi61pdb335n18xm8rfwddckwv0vg8n7fii5abrrx47vnqcj";
}) (args // { inherit overlays; })

