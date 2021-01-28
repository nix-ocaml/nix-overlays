args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2021-01-26";
  url = https://github.com/nixos/nixpkgs/archive/891f607d5301d6730cb1f9dcf3618bcb1ab7f10e.tar.gz;
  sha256 = "1cr39f0sbr0h5d83dv1q34mcpwnkwwbdk5fqlyqp2mnxghzwssng";
}) (args // { inherit overlays; })

