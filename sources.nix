args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-11-12";
  url = https://github.com/nixos/nixpkgs/archive/a371c1071161104d329f6a85d922fd92b7cbab63.tar.gz;
  sha256 = "1k5wa16wyb1byk5xfjlq4m518gsw6g1kypx4xb09k3inni13p0r4";
}) (args // { inherit overlays; })

