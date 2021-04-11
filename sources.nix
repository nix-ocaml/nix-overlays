args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-04-11";
    url = https://github.com/nixos/nixpkgs/archive/764448055551.tar.gz;
    sha256 = "0dlp5j1w4iwciqazizyhij6xpipynm70sarf2z2iqxf966cmr706";
  })
  (args // { inherit overlays; })
