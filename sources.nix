args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-04-04";
    url = https://github.com/nixos/nixpkgs/archive/8b65ff2559c1.tar.gz;
    sha256 = "0pdha58pjc59dd6s0pf0y4rilzphxijik8zjvgjlb1q4yz5j0prr";
  })
  (args // { inherit overlays; })
