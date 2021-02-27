args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-02-27";
    url = https://github.com/nixos/nixpkgs/archive/5df05c902cde398e056eb6271d5fe13e418db4c6.tar.gz;
    sha256 = "12plc7k251z1dmmrd29lyrpw0xmjvmf79yj568aapzrcki5mrw74";
  })
  (args // { inherit overlays; })
