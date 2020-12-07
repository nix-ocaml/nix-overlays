args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-12-03";
  url = https://github.com/nixos/nixpkgs/archive/296793637b22bdb4d23b479879eba0a71c132a66.tar.gz;
  sha256 = "0j09yih9693w5vjx64ikfxyja1ha7pisygrwrpg3wfz3sssglg69";
}) (args // { inherit overlays; })

