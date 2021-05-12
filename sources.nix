args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-05-12";
    url = https://github.com/nixos/nixpkgs/archive/ca26ea50d667.tar.gz;
    sha256 = "186fnj3dzv07bh5mh5wcw2lzcs9nidpvg48814xz2z78ifv09w2f";
  })
  (args // { inherit overlays; })
