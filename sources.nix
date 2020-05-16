args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-05-15";
  url = https://github.com/nixos/nixpkgs/archive/32b8ed738096bafb4cdb7f70347a0f63f9f40151.tar.gz;
  sha256 = "04x5lqw689mfkxzrb53393ssdx2bma8wv0i3hrfsp3d291b2qapx";
}) (args // { inherit overlays; })
