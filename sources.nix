args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-03-02";
    url = https://github.com/nixos/nixpkgs/archive/d12574353329.tar.gz;
    sha256 = "072n4vg6k82f0ifxvddmnqpvpk5saf6yg9jiqlxm573vs4x272gh";
  })
  (args // { inherit overlays; })
