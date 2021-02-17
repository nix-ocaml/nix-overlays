args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-02-14";
    url = https://github.com/nixos/nixpkgs/archive/64b4617883844efe0cc20163e007ee636462eb18.tar.gz;
    sha256 = "1vqqllxzdvvarwydv6yx0qwwl9shqla08ijabvmydi1kwc6388ww";
  })
  (args // { inherit overlays; })
