args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-06-18";
  url = https://github.com/nixos/nixpkgs/archive/9480bae337095fd24f61380bce3174fdfe926a00.tar.gz;
  sha256 = "1n5bnnral5w60kf68d9jvs7px1w3hx53d8pyg9yxkf1s2n3791j2";
}) (args // { inherit overlays; })

