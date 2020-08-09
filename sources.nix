args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-08-08";
  url = https://github.com/nixos/nixpkgs/archive/b50ef9afa11b384c72f7123ca4760ebc6d199fe8.tar.gz;
  sha256 = "0b6xjysxydiax765sia3dpnc3xi648aq4zjlxpiqzsh3hpsq0ch8";
}) (args // { inherit overlays; })

