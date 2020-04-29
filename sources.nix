args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-04-25";
  url = https://github.com/nixos/nixpkgs/archive/7c399a4ee080f33cc500a3fda33af6fccfd617bd.tar.gz;
  sha256 = "0vqljvz5yrc8i3nj3d5xiiv475yydscckfc9z0hpran9q2rh4md1";
}) (args // { inherit overlays; })
