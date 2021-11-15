{ buildPackages, lib, callPackage }:
# Loosely adapted from https://github.com/serokell/tezos-packaging/blob/b7617f99/nix/static.nix

[
  # The OpenSSL override in `overlays.nix` would cause curl and its transitive
  # closure to be recompiled because of its use within the fetchers. So for now
  # we use the native fetchers.
  # This should be revisited in the future, as it makes the fetchers
  # unusable at runtime in the target env. XXX(anmonteiro: is this true?)
  (self: super:
    lib.filterAttrs (n: _: lib.hasPrefix "fetch" n) buildPackages)

  (import ./overlays.nix)

  (lib.overlayOcamlPackages [ (callPackage ./ocaml.nix { }) ])
]
