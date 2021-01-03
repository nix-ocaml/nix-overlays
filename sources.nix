args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2021-01-03";
  url = https://github.com/nixos/nixpkgs/archive/56bb1b0f7a33e5d487dc2bf2e846794f4dcb4d01.tar.gz;
  sha256 = "1wl5yglgj3ajbf2j4dzgsxmgz7iqydfs514w73fs9a6x253wzjbs";
}) (args // { inherit overlays; })

