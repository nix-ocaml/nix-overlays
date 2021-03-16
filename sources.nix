args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-03-15";
    url = https://github.com/nixos/nixpkgs/archive/fa5c65b7b3e2.tar.gz;
    sha256 = "0g028722wh6baai5dsvirk178m22ijpp6nk7855lc0rffwxg0zns";
  })
  (args // { inherit overlays; })
