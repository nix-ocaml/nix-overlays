args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-09-12";
    url = https://github.com/nixos/nixpkgs/archive/a54d2e72e282.tar.gz;
    sha256 = "0wvd7s75ilbi7c91sp850l8akfkx70jd0yk7hc2r0v3hcyzf8ldw";
  })
  (args // { inherit overlays; })
