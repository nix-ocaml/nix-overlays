args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-07-21";
  url = https://github.com/nixos/nixpkgs/archive/5717d9d2f7ca0662291910c52f1d7b95b568fec2.tar.gz;
  sha256 = "17gxd2f622pyss3r6cjngdav6wzdbr31d7bqx9z2lawxg47mmk1l";
}) (args // { inherit overlays; })

