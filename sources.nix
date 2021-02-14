args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-02-14";
    url = https://github.com/nixos/nixpkgs/archive/ff96a0fa5635770390b184ae74debea75c3fd534.tar.gz;
    sha256 = "0dc612yhbcn2cc4rmnrhbkmpiyzg0ldkd8g2r7x7011bc9q3kc6y";
  })
  (args // { inherit overlays; })
