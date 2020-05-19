args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-05-19";
  url = https://github.com/nixos/nixpkgs/archive/0f5ce2fac0c726036ca69a5524c59a49e2973dd4.tar.gz;
  sha256 = "0nkk492aa7pr0d30vv1aw192wc16wpa1j02925pldc09s9m9i0r3";
}) (args // { inherit overlays; })
