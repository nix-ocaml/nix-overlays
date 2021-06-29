args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-06-26";
    url = https://github.com/nixos/nixpkgs/archive/e85975942742.tar.gz;
    sha256 = "0zg5c9if4dlk4f0w14439ixjv50m04yfxf0l3bmrhhsgq1f6yk0m";
  })
  (args // { inherit overlays; })
