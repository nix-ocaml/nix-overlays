args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2021-01-31";
  url = https://github.com/nixos/nixpkgs/archive/5ff6700bb824a6d824fa021550a5596f6c3f64e7.tar.gz;
  sha256 = "16fiqgvq95d9cmq3ra6id0zyzmqqn7d7287y7igag7g53lrfbjqp";
}) (args // { inherit overlays; })

