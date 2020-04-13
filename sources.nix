args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-04-13";
  url = https://github.com/nixos/nixpkgs/archive/8686922e68dfce2786722acad9593ad392297188.tar.gz;
  sha256 = "1pc92s1nbr9hlsmzlf8w2pc90rlma649y3fvyfww0sbcwn0lb65n";
}) (args // { inherit overlays; })
