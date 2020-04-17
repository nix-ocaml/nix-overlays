args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-04-13";
  url = https://github.com/nixos/nixpkgs/archive/b61999e4ad60c351b4da63ae3ff43aae3c0bbdfb.tar.gz;
  sha256 = "0cggpdks4qscyirqwfprgdl91mlhjlw24wkg0riapk5f2g2llbpq";
}) (args // { inherit overlays; })
