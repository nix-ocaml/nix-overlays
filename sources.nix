args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-02-20";
    url = https://github.com/nixos/nixpkgs/archive/9816b99e71c3504b0b4c1f8b2e004148460029d4.tar.gz;
    sha256 = "1dpz36i3vx0c1wmacrki0wsf30if8xq3bnj71g89rsbxyi87lhcm";
  })
  (args // { inherit overlays; })
