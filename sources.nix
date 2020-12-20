args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-12-19";
  url = https://github.com/nixos/nixpkgs/archive/3c6445b97e971a723999dbd5b2005eb0f149f69c.tar.gz;
  sha256 = "0sfdxhfq7k6arnijymzhpx2m69f8mg0k12jnvd60vrdslj452k2p";
}) (args // { inherit overlays; })

