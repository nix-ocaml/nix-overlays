args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-12-03";
  url = https://github.com/nixos/nixpkgs/archive/83cbad92d73216bb0d9187c56cce0b91f9121d5a.tar.gz;
  sha256 = "12g7d0rbw6s2zb6aq1scv59p6b5xzgsqic72pf272bhsa1bymbs0";
}) (args // { inherit overlays; })

