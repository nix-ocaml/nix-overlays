args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-09-13";
  url = https://github.com/nixos/nixpkgs/archive/e0759a49733dfc3aa225b8a7423c00da6e1ecb67.tar.gz;
  sha256 = "1lnaifrbdmvbmz25404z7xpfwaagscs1i80805fyrrs1g27h21qb";
}) (args // { inherit overlays; })

