args@{ overlays ? [ (import ./.) ], ... }:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

import (builtins.fetchTarball {
  name = "nixos-unstable-2020-12-30";
  url = https://github.com/nixos/nixpkgs/archive/733e537a8ad76fd355b6f501127f7d0eb8861775.tar.gz;
  sha256 = "1rjvbycd8dkkflal8qysi9d571xmgqq46py3nx0wvbzwbkvzf7aw";
}) (args // { inherit overlays; })

