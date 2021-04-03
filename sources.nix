args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-03-30";
    url = https://github.com/nixos/nixpkgs/archive/905ecb920edc.tar.gz;
    sha256 = "1qwxh84k4w82vvwxfnxdgvjj19ysznpwq66rqvkx269qm7ygzlws";
  })
  (args // { inherit overlays; })
