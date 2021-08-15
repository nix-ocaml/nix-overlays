args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-08-15";
    url = https://github.com/nixos/nixpkgs/archive/db6e428bfa2d.tar.gz;
    sha256 = "0c2ja9cn2lj7ijlsfi0vjwi3l25c48s4ds6k6qfm56hjbbdkl8r7";
  })
  (args // { inherit overlays; })
