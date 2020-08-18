args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-08-17";
  url = https://github.com/nixos/nixpkgs/archive/1e3f09feaa5667be4ed6eca96a984b4642420b83.tar.gz;
  sha256 = "1vcmzjzzmcy4mvlyshv9j3cri4kvxndjqk3ziqafc8ik0vv117p8";
}) (args // { inherit overlays; })

