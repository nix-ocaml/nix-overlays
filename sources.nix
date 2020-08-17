args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-08-16";
  url = https://github.com/nixos/nixpkgs/archive/16fc531784ac226fb268cc59ad573d2746c109c1.tar.gz;
  sha256 = "0qw1jpdfih9y0dycslapzfp8bl4z7vfg9c7qz176wghwybm4sx0a";
}) (args // { inherit overlays; })

