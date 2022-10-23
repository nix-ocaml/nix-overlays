# Loosely adapted from https://github.com/serokell/tezos-packaging/blob/b7617f99/nix/static.nix

self: super:

let
  inherit (super) stdenv lib;

in

{
  libpq = super.libpq.overrideAttrs (_: { dontDisableStatic = true; });
  libev-oc = super.libev-oc.override { static = true; };
  zlib-oc = super.zlib-oc.override { static = true; splitStaticOutput = false; };
  openssl-oc = super.openssl-oc.override { static = true; };
  gmp-oc = super.gmp-oc.override { withStatic = true; };
  libffi-oc = super.libffi-oc.overrideAttrs (_: { dontDisableStatic = true; });
  libxml2 = super.libxml2.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ self.zlib-oc ];
  });
} // super.lib.overlayOCamlPackages {
  inherit super;
  overlays = [ (super.callPackage ./ocaml.nix { }) ];
  updateOCamlPackages = true;
}
