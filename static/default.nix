# Loosely adapted from https://github.com/serokell/tezos-packaging/blob/b7617f99/nix/static.nix

self: super:

let
  inherit (super) stdenv lib;

in

{
  libev-oc = super.libev-oc.override { static = true; };
  libffi-oc = super.libffi-oc.overrideAttrs (_: { dontDisableStatic = true; });
  libpq = super.libpq.overrideAttrs (_: { dontDisableStatic = true; });
  libxml2 = super.libxml2.override { zlib = self.zlib-oc; };
  gmp-oc = super.gmp-oc.override { withStatic = true; };
  openssl-oc = super.openssl-oc.override { static = true; };

  pcre-oc = super.pcre-oc.overrideAttrs (_: {
    dontDisableStatic = true;
  });

  sqlite-oc = super.sqlite-oc.overrideAttrs (o: {
    dontDisableStatic = true;
  });
  zlib-oc = super.zlib-oc.override { static = true; splitStaticOutput = false; };
  zstd-oc = (super.zstd-oc.override { static = true; });
} // super.lib.overlayOCamlPackages {
  inherit super;
  overlays = [ (super.callPackage ./ocaml.nix { }) ];
  updateOCamlPackages = true;
}
