args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-07-02";
  url = https://github.com/nixos/nixpkgs/archive/55668eb671b915b49bcaaeec4518cc49d8de0a99.tar.gz;
  sha256 = "0b2mrrjsdpxpyvnv98dph5av3xjps1mbd87x8510mnc4pfa2zc8z";
}) (args // { inherit overlays; })

