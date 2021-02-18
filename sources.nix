args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-02-14";
    url = https://github.com/nixos/nixpkgs/archive/6b1057b452c55bb3b463f0d7055bc4ec3fd1f381.tar.gz;
    sha256 = "10qfg11g8m0q2k3ibcm0ivjq494gqynshm3smjl1rfn5ifjf5fz8";
  })
  (args // { inherit overlays; })
