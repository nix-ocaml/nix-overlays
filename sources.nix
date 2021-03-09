args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-03-09";
    url = https://github.com/nixos/nixpkgs/archive/0867f6274247.tar.gz;
    sha256 = "09ajwk2aafhy2xiqlcp5swlhhfiwdjb3dbfm8p8j81h28vli7p94";
  })
  (args // { inherit overlays; })
