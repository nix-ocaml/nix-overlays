args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-04-17";
    url = https://github.com/nixos/nixpkgs/archive/90725c7c6dd0cfdce5eb27ae0df45b8a1ecea739.tar.gz;
    sha256 = "04hv6br4xb81hymma8agh95dxfi8j80426s7hf9zwnnikmv2qmdg";
  })
  (args // { inherit overlays; })
