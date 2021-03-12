args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-03-12";
    url = https://github.com/nixos/nixpkgs/archive/916ee862e87a.tar.gz;
    sha256 = "165byy4hgg44w4ks1l289yx98bifqwyk6amil9rq7z7978d5lsj9";
  })
  (args // { inherit overlays; })
