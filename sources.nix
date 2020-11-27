args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-11-23";
  url = https://github.com/nixos/nixpkgs/archive/48feb84a9d91ac2601ac33e660d9f6c76f476a1e.tar.gz;
  sha256 = "0ylrccfzs2y4hw5ka36yhzsr9zmwh230dk6psxm4vmpz4qn2xja7";
}) (args // { inherit overlays; })

