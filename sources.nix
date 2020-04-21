args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-04-13";
  url = https://github.com/nixos/nixpkgs/archive/22a3bf9fb9edad917fb6cd1066d58b5e426ee975.tar.gz;
  sha256 = "089hqg2r2ar5piw9q5z3iv0qbmfjc4rl5wkx9z16aqnlras72zsa";
}) (args // { inherit overlays; })
