args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-05-14";
  url = https://github.com/nixos/nixpkgs/archive/8ba41a1e14961fe43523f29b8b39acb569b70e72.tar.gz;
  sha256 = "0c2wn7si8vcx0yqwm92dpry8zqjglj9dfrvmww6ha6ihnjl6mfhh";
}) (args // { inherit overlays; })
