args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-06-24";
  url = https://github.com/nixos/nixpkgs/archive/22a81aa5fc15b2d41b12f7160a71cd4a9f3c3fa1.tar.gz;
  sha256 = "14gx5fsqibdn2cxp7gymfrz2vcnwiwwjnxqlnysczz8dqihnrpa7";
}) (args // { inherit overlays; })

