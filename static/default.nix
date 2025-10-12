# Loosely adapted from https://github.com/serokell/tezos-packaging/blob/b7617f99/nix/static.nix

self: super:

let
  inherit (super) stdenv lib;

in

{
  icu = super.icu.overrideAttrs (o: {
    configureFlags = o.configureFlags ++ [ "--enable-static" ];
  });
  readline-oc = super.readline-oc.overrideAttrs (o: {
    configureFlags = (o.configureFlags or [ ]) ++ [ "--enable-static" "--disable-shared" ];
  });

  libev-oc = super.libev-oc.override { static = true; };
  libffi-oc = super.libffi-oc.overrideAttrs (_: { dontDisableStatic = true; });
  libpq = super.libpq.overrideAttrs (_: { dontDisableStatic = true; });
  lz4-oc = super.lz4-oc.overrideAttrs (_: {
    cmakeFlags = [ "-DBUILD_STATIC_LIBS=TRUE" ];
  });
  gmp-oc = super.gmp-oc.override { withStatic = true; };
  openssl-oc = super.openssl-oc.override { static = true; };

  pcre-oc = super.pcre-oc.overrideAttrs (_: {
    dontDisableStatic = true;
  });

  rdkafka-oc = (super.rdkafka-oc.override {
    zstd = self.zstd-oc;
    zlib = self.zlib-oc;
    openssl = self.openssl-oc;
  }).overrideAttrs (o: {
    postPatch = ''
      ${o.postPatch}
      # https://github.com/confluentinc/librdkafka/pull/4281
      substituteInPlace mklove/Makefile.base --replace-fail 'ar -r' '$(AR) -r'
    '';
    configureFlags = [ "--enable-static" ];
    STATIC_LIB_libzstd = "${self.zstd-oc}/lib/libzstd.a";
    propagatedBuildInputs = o.buildInputs;
  });

  sqlite-oc = (super.sqlite-oc.override { zlib = self.zlib-oc; }).overrideAttrs (o: {
    dontDisableStatic = true;
  });

  zlib-oc = super.zlib-oc.override {
    static = true;
    splitStaticOutput = false;
  };

  zstd-oc = super.zstd-oc.override { static = true; };
} // super.lib.overlayOCamlPackages {
  inherit self super;
  overlays = [ (super.callPackage ./ocaml.nix { }) ];
  updateOCamlPackages = true;
}
