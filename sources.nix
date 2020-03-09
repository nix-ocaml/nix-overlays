args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-03-08";
  url = https://github.com/nixos/nixpkgs/archive/d008a34.tar.gz;
  sha256 = "082918aj1gsm581s8qqq9fjm20qzihxygplp6jy07asip3rni54q";
}) (args // { inherit overlays; })
