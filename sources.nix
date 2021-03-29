args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-03-25";
    url = https://github.com/nixos/nixpkgs/archive/b722e3ff4c1a.tar.gz;
    sha256 = "1yl7a84k0mmj8yyic3n4pnc2xji1315s1mqa83awsf183md8qkfg";
  })
  (args // { inherit overlays; })
