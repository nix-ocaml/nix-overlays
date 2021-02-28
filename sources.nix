args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-02-27";
    url = https://github.com/nixos/nixpkgs/archive/b51b5a104b719721cabf0c7018da82e02014cbbd.tar.gz;
    sha256 = "1pfag7wjv3wngywpii338cgfk5dlgap8ldxhwgizbr98i5yjk5ix";
  })
  (args // { inherit overlays; })
