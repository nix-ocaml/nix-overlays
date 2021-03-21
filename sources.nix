args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-03-20";
    url = https://github.com/nixos/nixpkgs/archive/f5e8bdd07d1a.tar.gz;
    sha256 = "1fmwkb2wjfrpx8fis4x457vslam0x8vqlpfwqii6p9vm33dyxhzk";
  })
  (args // { inherit overlays; })
