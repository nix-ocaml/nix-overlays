args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-07-30";
  url = https://github.com/nixos/nixpkgs/archive/8e2b14aceb1d40c7e8b84c03a7c78955359872bb.tar.gz;
  sha256 = "0zzjpd9smr7rxzrdf6raw9kbj42fbvafxb5bz36lcxgv290pgsm8";
}) (args // { inherit overlays; })

