args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-03-13";
  url = https://github.com/nixos/nixpkgs/archive/0729b8c55e0dfaf302af4c57546871d47a652048.tar.gz;
  sha256 = "0warcibx94rn6rvm92rg8v91jf5ddy1j0dwlznwav3y99fcx8sjk";
}) (args // { inherit overlays; })
