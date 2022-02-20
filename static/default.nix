{ buildPackages, pkgsStatic }:
# Loosely adapted from https://github.com/serokell/tezos-packaging/blob/b7617f99/nix/static.nix

[
  (self: super:
    super.lib.overlayOcamlPackages [ (super.callPackage ./ocaml.nix { }) ]
      self
      super)

  (import ./overlays.nix { inherit pkgsStatic; })
]
