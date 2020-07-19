args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-07-18";
  url = https://github.com/nixos/nixpkgs/archive/a5cc7d3197705f933d88e97c0c61849219ce76c1.tar.gz;
  sha256 = "0b7y2nv5nj776zh9jwir8fq1qrgcqpaap05qxlxp9qfngw12k6ji";
}) (args // { inherit overlays; })

