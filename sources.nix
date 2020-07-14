args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-07-14";
  url = https://github.com/nixos/nixpkgs/archive/c71518e75bf067fb639d44264fdd8cf80f53d75a.tar.gz;
  sha256 = "0hwa79prsqgvfwd3ah54nl0wh73q215z7np4k6y0pd6zr3m17vxs";
}) (args // { inherit overlays; })

