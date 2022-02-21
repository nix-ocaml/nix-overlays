{ pkgsStatic }:

self: super:

let
  inherit (super) stdenv lib;
  isStatic = stdenv.hostPlatform.isStatic;
  renameForOCaml = n: p:
    if isStatic
    then lib.nameValuePair n p
    else
      lib.nameValuePair "${n}-oc" p;

in

{
  inherit (pkgsStatic) libev;
  libpq = super.libpq.overrideAttrs (_: { dontDisableStatic = true; });
  zlib-oc = super.zlib.override { static = true; splitStaticOutput = false; };
  openssl-oc = super.openssl.override { static = true; };
  gmp-oc = super.gmp.override { withStatic = true; };
  libffi-oc = super.libffi.overrideAttrs (_: { dontDisableStatic = true; });
}
# // (
# lib.mapAttrs' renameForOCaml { inherit (pkgsStatic) zlib openssl; }
# )
