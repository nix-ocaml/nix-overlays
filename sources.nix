args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-02-03";
    url = https://github.com/nixos/nixpkgs/archive/7cbec40a09533dd9c525d6ab94dddfe77768101a.tar.gz;
    sha256 = "006fns0kxs9n32cg6f4p0zyaxxsyidwsa152flpsbaky1c6drn96";
  })
  (args // { inherit overlays; })
