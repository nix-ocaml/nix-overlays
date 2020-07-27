args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-07-21";
  url = https://github.com/nixos/nixpkgs/archive/28fce082c8ca1a8fb3dfac5c938829e51fb314c8.tar.gz;
  sha256 = "1pzmqgby1g9ypdn6wgxmbhp6hr55dhhrccn67knrpy93vib9wf8r";
}) (args // { inherit overlays; })

