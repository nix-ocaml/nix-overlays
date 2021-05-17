args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import
  (builtins.fetchTarball {
    name = "nixos-unstable-2021-05-12";
    url = https://github.com/nixos/nixpkgs/archive/b2cd6ba7f5ed.tar.gz;
    sha256 = "1qdj4g2s6iwj6h2y5ddk5xqd9mnxqi4n0lyizkw80nb7nync77nq";
  })
  (args // { inherit overlays; })
