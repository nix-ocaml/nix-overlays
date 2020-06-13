args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-06-06";
  url = https://github.com/nixos/nixpkgs/archive/029a5de08390bb03c3f44230b064fd1850c6658a.tar.gz;
  sha256 = "156rj5kch114radmni79rm6pg7g1i10wrpm1ghvf0fwns7jfrm3j";
}) (args // { inherit overlays; })

