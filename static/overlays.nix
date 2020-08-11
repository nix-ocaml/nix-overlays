{ pkgsNative, lib, fixOCaml ? null, ocamlVersion }:

# An important note about these overlays: `pkgsStatic` propagates all build
# inputs. See: https://github.com/NixOS/nixpkgs/issues/83667

let
  # TODO: explain difference: shared vs no shared support
  fixOCamlCross = if fixOCaml != null then
    fixOCaml
  else
    ocaml: ocaml.overrideDerivation (o: {
      preConfigure = ''
        configureFlagsArray+=("PARTIALLD=$LD -r" "ASPP=$CC -c" "LIBS=-static")
      '';
      configureFlags = [
        "--enable-static"
        "--disable-shared"
        "-host ${o.stdenv.hostPlatform.config}"
        "-target ${o.stdenv.targetPlatform.config}"
      ];
    });
  removeUnknownConfigureFlags = f: with lib;
    remove "--disable-shared"
    (remove "--enable-static" f);
  dds = x: x.overrideAttrs (o: { dontDisableStatic = true; });
  fixOCamlPackage = b:
    b.overrideAttrs (o: {
      configurePlatforms = [];
      nativeBuildInputs = (o.nativeBuildInputs or []) ++ (o.buildInputs or []) ++ (o.propagatedBuildInputs or []);
      buildInputs = (o.buildInputs or []) ++ (o.nativeBuildInputs or []);
      # propagatedNativeBuildInputs = (o.propagatedNativeBuildInputs or [ ]) ++ (o.propagatedBuildInputs or [ ]);
    });

in [
  # The OpenSSL override below would cause curl and its transitive closure
  # to be recompiled because of its use within the fetchers. So for now we
  # use the native fetchers.
  # This should be revisited in the future, as it makes the fetchers
  # unusable at runtime in the target env
  (self: super:
    lib.filterAttrs (n: _: lib.hasPrefix "fetch" n) pkgsNative)

  (self: super: {
    ocaml = self.ocaml-ng."ocamlPackages_${ocamlVersion}".ocaml;

    opaline = fixOCamlPackage (super.opaline.override {
      ocamlPackages = self.ocaml-ng."ocamlPackages_${ocamlVersion}";
    });

    ocamlPackages = self.ocaml-ng."ocamlPackages_${ocamlVersion}";
    ocamlPackages_latest = self.ocaml-ng."ocamlPackages_${ocamlVersion}";

    # zlib = super.zlib.override {
      # static = true;
      # shared = false;
      # splitStaticOutput = false;
    # };

    gmp =
      if super.stdenv.buildPlatform != super.stdenv.hostPlatform
      then dds super.gmp
      else super.gmp;

    libpq =
      if super.stdenv.buildPlatform != super.stdenv.hostPlatform
      then dds super.libpq
      else super.libpq;

    libev =
      if super.stdenv.hostPlatform != super.stdenv.buildPlatform
      then super.libev.overrideDerivation (o :{
        configureFlags = [ "LDFLAGS=-static" ];
        dontDisableStatic = true;
      })
      else super.libev;

    openssl =
      if super.stdenv.buildPlatform != super.stdenv.hostPlatform
      then (super.openssl_1_1.override { static = true; }).overrideAttrs (o: {
        configureFlags = removeUnknownConfigureFlags o.configureFlags;
      })
      else super.openssl;

    ocaml-ng = super.ocaml-ng // {
      "ocamlPackages_${ocamlVersion}" =
        ((super.ocaml-ng."ocamlPackages_${ocamlVersion}".overrideScope'
          # For convenience, add our own overlays to the static packages.
          # It's important that this happens before the next
          # `overrideScope'` call, as that will fix our packages for
          # cross-compilation
          (super.callPackage ../ocaml {})).overrideScope' (oself: osuper:

          lib.mapAttrs
          (_: p: if p ? overrideAttrs then fixOCamlPackage p else p)
          osuper)).overrideScope' (oself: osuper: {
            ocaml = fixOCamlCross osuper.ocaml;

            zarith = osuper.zarith.overrideDerivation (o: {
              configureFlags = o.configureFlags ++ [
                "-host ${o.stdenv.hostPlatform.config} -prefixnonocaml ${o.stdenv.hostPlatform.config}-"
              ];
            });
            ppxfind = osuper.ppxfind.overrideAttrs (o: { dontStrip = true; });
          });
    };
  })
]
