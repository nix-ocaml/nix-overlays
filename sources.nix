args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-04-07";
    url = https://github.com/nixos/nixpkgs/archive/de679c57ca5.tar.gz;
    sha256 = "0xhw2k33zxcxvqm83mch9izkxlxhfc6q6qsijky58qzn8x9854w0";
  })
  (args // { inherit overlays; })
