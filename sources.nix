args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-04-10";
  url = https://github.com/nixos/nixpkgs/archive/807ca93fadd5197c2260490de0c76e500562dc05.tar.gz;
  sha256 = "10yq8bnls77fh3pk5chkkb1sv5lbdgyk1rr2v9xn71rr1k2x563p";
}) (args // { inherit overlays; })
