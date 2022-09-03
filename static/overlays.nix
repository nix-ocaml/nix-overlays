{ pkgsStatic }:

final: prev:

let
  inherit (prev) stdenv lib;

in

{
  inherit (pkgsStatic) libev;
  libpq = prev.libpq.overrideAttrs (_: { dontDisableStatic = true; });
  zlib-oc = prev.zlib-oc.override { static = true; splitStaticOutput = false; };
  openssl-oc = prev.openssl-oc.override { static = true; };
  gmp-oc = prev.gmp-oc.override { withStatic = true; };
  libffi-oc = prev.libffi-oc.overrideAttrs (_: { dontDisableStatic = true; });
  libxml2 = prev.libxml2.overrideAttrs (o: {
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ final.zlib-oc ];
  });
}
