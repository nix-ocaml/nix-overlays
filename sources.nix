args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-03-25";
    url = https://github.com/nixos/nixpkgs/archive/c0e5d0b73afa.tar.gz;
    sha256 = "0432c51ghpsa40dyc6a9k2gk2cnv3hcd9dxw6zcqnji7zrblm5jq";
  })
  (args // { inherit overlays; })
