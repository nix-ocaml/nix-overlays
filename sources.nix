args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-03-03";
    url = https://github.com/nixos/nixpkgs/archive/e061350a361d.tar.gz;
    sha256 = "04lqpi25fkyzqflih3hixrrrbjv733mh1izgw4n03ar08w6dnm4k";
  })
  (args // { inherit overlays; })
