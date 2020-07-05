args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-07-04";
  url = https://github.com/nixos/nixpkgs/archive/f7c7509ecd0a49a2a7402cebb89351166bb136d2.tar.gz;
  sha256 = "177z9zsvxgv968r6cjw6y9v6kc30npdk750ivi88cbc84yyzwjfm";
}) (args // { inherit overlays; })

