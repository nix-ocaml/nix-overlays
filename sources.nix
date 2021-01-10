args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2021-01-09";
  url = https://github.com/nixos/nixpkgs/archive/257cbbcd3ab7bd96f5d24d50adc807de7c82e06d.tar.gz;
  sha256 = "0g3n725kjk2fc9yn9rvdjwci4mrx58yrdgp3waby9ky3d5xhcaw4";
}) (args // { inherit overlays; })

