args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-09-12";
    url = https://github.com/nixos/nixpkgs/archive/db88608d8c81.tar.gz;
    sha256 = "078nmdgsqb5khza9bifs29h6lw6n2m38y699g27yrwyp7jhsv74m";
  })
  (args // { inherit overlays; })
