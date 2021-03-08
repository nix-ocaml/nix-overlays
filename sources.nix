args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-03-07";
    url = https://github.com/nixos/nixpkgs/archive/1005b14672de.tar.gz;
    sha256 = "0dljrdm9icdid8zx1y1lmlldl2i0xrin6fqjb1nwn0nbdmwqshws";
  })
  (args // { inherit overlays; })
