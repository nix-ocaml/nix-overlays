args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-03-28";
  url = https://github.com/nixos/nixpkgs/archive/39247f8d04c04b3ee629a1f85aeedd582bf41cac.tar.gz;
  sha256 = "1q7asvk73w7287d2ghgya2hnvn01szh65n8xczk4x2b169c5rfv0";
}) (args // { inherit overlays; })
