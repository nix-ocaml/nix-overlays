args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-05-26";
    url = https://github.com/nixos/nixpkgs/archive/d4b7485fb66.tar.gz;
    sha256 = "1crih90j98cgd36xxy0q7fv829a0h9w5ha5sa31nr1yn54lj3z7m";
  })
  (args // { inherit overlays; })
