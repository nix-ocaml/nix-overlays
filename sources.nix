args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2021-01-21";
  url = https://github.com/nixos/nixpkgs/archive/33fc9b1c6dec3287425ad88e60e6534e33d1f9b9.tar.gz;
  sha256 = "1pvfrbp5qlwiv20b35hc74mfpvgi08q6naz1gwlldpxdmi6173gd";
}) (args // { inherit overlays; })

