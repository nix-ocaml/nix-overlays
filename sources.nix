args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-02-25";
    url = https://github.com/nixos/nixpkgs/archive/aed8afc300d82099890aafeeb631e5fc78d3469c.tar.gz;
    sha256 = "0wdpwj60s7r3y3ixf38ifqnf64qh7niydwgvpmkanvlc1clkhi8h";
  })
  (args // { inherit overlays; })
