args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-04-29";
    url = https://github.com/nixos/nixpkgs/archive/8f70383650a1.tar.gz;
    sha256 = "1gsnl8prbrgc9ydgls0gk7gyfrg6jzjzjgavlqw07w19fs5lya8b";
  })
  (args // { inherit overlays; })
