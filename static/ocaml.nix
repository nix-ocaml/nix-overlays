{ lib, callPackage }:
let
  removeUnknownConfigureFlags = f: with lib;
    remove "--disable-shared"
      (remove "--enable-static" f);
  fixOCaml = ocaml:
    (ocaml.override { useX11 = false; }).overrideAttrs (o: {
      dontUpdateAutotoolsGnuConfigScripts = true;
      preConfigure = ''
        configureFlagsArray+=("PARTIALLD=$LD -r" "ASPP=$CC -c" "LIBS=-static")
      '';
    });

  fixOCamlPackage = b:
    b.overrideAttrs (o: {
      configureFlags = removeUnknownConfigureFlags (o.configureFlags or [ ]);
      configurePlatforms = [ ];
      nativeBuildInputs = (o.nativeBuildInputs or [ ]) ++ (o.buildInputs or [ ]) ++ (o.propagatedBuildInputs or [ ]);
      buildInputs = (o.buildInputs or [ ]) ++ (o.nativeBuildInputs or [ ]);
    });

in
(oself: osuper:
  lib.mapAttrs (_: p: if p ? overrideAttrs then fixOCamlPackage p else p) osuper // {
    ocaml = fixOCaml osuper.ocaml;

    zarith = osuper.zarith.overrideDerivation (o: {
      configureFlags = o.configureFlags ++ [
        "-host ${o.stdenv.hostPlatform.config} -prefixnonocaml ${o.stdenv.hostPlatform.config}-"
      ];
    });
    ppxfind = osuper.ppxfind.overrideAttrs (o: { dontStrip = true; });
  })
