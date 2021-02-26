args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-02-26";
    url = https://github.com/nixos/nixpkgs/archive/8e5a172d0c7c4aa0cced5ca90b2407e819b4e711.tar.gz;
    sha256 = "1dkis01brfz8mclgach1llqy72fjz8bvhcmycgfwjj7fmqp3mijl";
  })
  (args // { inherit overlays; })
