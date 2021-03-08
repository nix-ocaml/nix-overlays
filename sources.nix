args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-03-07";
    url = https://github.com/nixos/nixpkgs/archive/1005b14672de.tar.gz;
    sha256 = "1815gsqh6md3k5416g1hpk4x2718py2wg5qagkd8avpm8y149k5l";
  })
  (args // { inherit overlays; })
