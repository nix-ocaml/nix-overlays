args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-07-30";
  url = https://github.com/nixos/nixpkgs/archive/840c782d507d60aaa49aa9e3f6d0b0e780912742.tar.gz;
  sha256 = "14q3kvnmgz19pgwyq52gxx0cs90ddf24pnplmq33pdddbb6c51zn";
}) (args // { inherit overlays; })

