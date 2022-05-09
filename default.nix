{ system ? builtins.currentSystem
, extraOverlays ? [ ]
, ...
}@args:

# `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`

let
  flake = (import
    (
      fetchTarball {
        url = https://github.com/edolstra/flake-compat/archive/b4a3401.tar.gz;
        sha256 = "1qc703yg0babixi6wshn5wm2kgl5y1drcswgszh4xxzbrwkk9sv7";
      }
    )
    { src = ./.; }
  ).defaultNix;
in

flake.makePkgs {
  inherit system extraOverlays;
}
