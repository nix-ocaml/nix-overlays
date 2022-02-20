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
} // (
  lib.mapAttrs' renameForOCaml { inherit (pkgsStatic) zlib openssl; }
)
