args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-04-15";
    url = https://github.com/nixos/nixpkgs/archive/294d1925af6.tar.gz;
    sha256 = "0x0aafl20c087vhs2mmzga20bmafsn93p271ddc9lvjsgbny80wd";
  })
  (args // { inherit overlays; })
