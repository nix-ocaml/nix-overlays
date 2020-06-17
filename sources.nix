args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-06-06";
  url = https://github.com/nixos/nixpkgs/archive/0a146054bdf6f70f66de4426f84c9358521be31e.tar.gz;
  sha256 = "154ypjfhy9qqa0ww6xi7d8280h85kffqaqf6b6idymizga9ckjcd";
}) (args // { inherit overlays; })

