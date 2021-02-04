args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-02-03";
    url = https://github.com/nixos/nixpkgs/archive/9ff91f967cb6ad74bb621f5dfa07ce42a83c29dc.tar.gz;
    sha256 = "0n7ls06bkr7clsd5xb4h0fqlxqkp4m4wzf1ixkjqd2n44k18j3r6";
  })
  (args // { inherit overlays; })
