{ buildPackages, pkgsStatic }:
# Loosely adapted from https://github.com/serokell/tezos-packaging/blob/b7617f99/nix/static.nix

[
  (final: prev:
    prev.lib.overlayOCamlPackages {
      inherit prev;
      overlays = [ (prev.callPackage ./ocaml.nix { }) ];
      updateOCamlPackages = true;
    })

  (import ./overlays.nix { inherit pkgsStatic; })
]
