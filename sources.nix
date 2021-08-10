args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-08-09";
    url = https://github.com/nixos/nixpkgs/archive/d7b436eac259.tar.gz;
    sha256 = "0jyhrs7i4rm87w26fhmasr8qs0k1334qq5kba6r2im35jjq6x3cd";
  })
  (args // { inherit overlays; })
