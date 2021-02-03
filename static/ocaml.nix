{ lib, callPackage }:

let
  removeUnknownConfigureFlags = f: with lib;
    remove "--disable-shared"
    (remove "--enable-static" f);
  fixOCaml = ocaml:
    ((ocaml.override { useX11 = false; })
    .overrideAttrs (o: {
      hardeningDisable = ["pie"];
      configurePlatforms = [ ];
      dontUpdateAutotoolsGnuConfigScripts = true;
    }))
    .overrideDerivation(o: {
      preConfigure = ''
        configureFlagsArray+=("CC=$CC" "PARTIALLD=$LD -r" "ASPP=$CC -c" "LIBS=-static")
      '';
      # (if (lib.elem "--enable-flambda" o.configureFlags) then
      # ["--enable-flambda"] else []) ++
      configureFlags = (removeUnknownConfigureFlags o.configureFlags) ++ [
        "--enable-static"
        "-host ${o.stdenv.hostPlatform.config}"
        "-target ${o.stdenv.targetPlatform.config}"
      ];
    });

  dds = x: x.overrideAttrs (o: { dontDisableStatic = true; });
  fixOCamlPackage = b:
    b.overrideAttrs (o: {
      # hardeningDisable = ["pie"];
      configureFlags = removeUnknownConfigureFlags (o.configureFlags or []);
      configurePlatforms = [];
      nativeBuildInputs = (o.nativeBuildInputs or []) ++ (o.buildInputs or []) ++ (o.propagatedBuildInputs or []);
      buildInputs = (o.buildInputs or []) ++ (o.nativeBuildInputs or []);
      # propagatedNativeBuildInputs = (o.propagatedNativeBuildInputs or [ ]) ++ (o.propagatedBuildInputs or [ ]);
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
      }
  )
