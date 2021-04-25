args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-04-25";
    url = https://github.com/nixos/nixpkgs/archive/93de027ee045.tar.gz;
    sha256 = "0lz73h01pzcgz8l20k1qawk20g7jcjnrppbxf1wvr8fq21dl4bj1";
  })
  (args // { inherit overlays; })
