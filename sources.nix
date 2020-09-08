args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-09-07";
  url = https://github.com/nixos/nixpkgs/archive/a31736120c5de6e632f5a0ba1ed34e53fc1c1b00.tar.gz;
  sha256 = "0xfjizw6w84w1fj47hxzw2vwgjlszzmsjb8k8cgqhb379vmkxjfl";
}) (args // { inherit overlays; })

