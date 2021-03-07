args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-03-07";
    url = https://github.com/nixos/nixpkgs/archive/05f5a981417.tar.gz;
    sha256 = "1v7q2jqw7w6fnv597yjr4x0bx22i57aawrp0321q1fnjqyfl69nx";
  })
  (args // { inherit overlays; })
