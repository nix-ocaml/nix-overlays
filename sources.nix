args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-03-30";
    url = https://github.com/nixos/nixpkgs/archive/04a2b269d892.tar.gz;
    sha256 = "15hgx2i71pqgvzv56jwzfs8rkhjbm35wk1i6mxrqbq6wd0y10isv";
  })
  (args // { inherit overlays; })
