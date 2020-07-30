args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-07-30";
  url = https://github.com/nixos/nixpkgs/archive/a45f68ccac476dc37ddf294530538f2f2cce5a92.tar.gz;
  sha256 = "0i19mrky9m73i601hczyfk25qqyr3j75idb72imdz55szc4vavzc";
}) (args // { inherit overlays; })

