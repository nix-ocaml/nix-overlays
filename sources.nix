args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-03-29";
    url = https://github.com/nixos/nixpkgs/archive/8e71416e5d4.tar.gz;
    sha256 = "0rzxx0rdkn88wrh3ilpnsy6zxwz5nh97ymvxmpy3ylb77kqln1g4";
  })
  (args // { inherit overlays; })
