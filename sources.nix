args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2021-01-18";
  url = https://github.com/nixos/nixpkgs/archive/68398d2dd50efc2d878bf0f83bbc8bc323b6b0e0.tar.gz;
  sha256 = "1bivcxnajll53ixwyl304fq22w5dg97fqbwk8imp6ipwq84bq5ga";
}) (args // { inherit overlays; })

