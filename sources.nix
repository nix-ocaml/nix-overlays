args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-11-18";
  url = https://github.com/nixos/nixpkgs/archive/a322b32e9d74fb476944ff6cfb55833dc69cfaaa.tar.gz;
  sha256 = "1r0mkiqxija75spnyksmh8x5j4smnrxv5f7768s81gsl570kls0l";
}) (args // { inherit overlays; })

