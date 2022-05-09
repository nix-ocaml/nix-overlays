{ buildPackages, pkgsStatic }:
# Loosely adapted from https://github.com/serokell/tezos-packaging/blob/b7617f99/nix/static.nix

[
  (self: super:
    super.lib.overlayOCamlPackages {
      pkgs = super;
      overlays = [ (super.callPackage ./ocaml.nix { }) ];
    })

  (import ./overlays.nix { inherit pkgsStatic; })
]
