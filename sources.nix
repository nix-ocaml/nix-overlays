args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-04-17";
    url = https://github.com/nixos/nixpkgs/archive/ebcf1f92fe2.tar.gz;
    sha256 = "16491gmhzhjb0alapap55jsbp88z8mp5gb2h8qpzsna92gqqbvfy";
  })
  (args // { inherit overlays; })
