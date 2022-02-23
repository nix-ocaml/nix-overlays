{ lib }:
let
  removeUnknownConfigureFlags = f: with lib;
    remove "--disable-shared"
      (remove "--enable-static" (if isList f then f else [ f ]));
  fixOCaml = ocaml:
    (ocaml.override { useX11 = false; }).overrideAttrs (o: {
      dontUpdateAutotoolsGnuConfigScripts = true;
      dontDisableStatic = true;
      preConfigure = ''
        configureFlagsArray+=("PARTIALLD=$LD -r" "ASPP=$CC -c" "LIBS=-static")
      '';
    });

  fixOCamlPackage = b:
    b.overrideAttrs (o: {
      configureFlags = removeUnknownConfigureFlags (o.configureFlags or [ ]);
      configurePlatforms = [ ];
      # Shouldn't need this after https://github.com/NixOS/nixpkgs/pull/145448
      # nativeBuildInputs = (o.nativeBuildInputs or [ ]) ++ (o.buildInputs or [ ]);
      # buildInputs = (o.buildInputs or [ ]) ++ (o.nativeBuildInputs or [ ]);
    });

in
(oself: osuper:
  lib.mapAttrs (_: p: if p ? overrideAttrs then fixOCamlPackage p else p) osuper // {
    ocaml = fixOCaml osuper.ocaml;

    zarith = osuper.zarith.overrideDerivation (o: {
      configureFlags = o.configureFlags ++ [
        "-prefixnonocaml ${o.stdenv.hostPlatform.config}-"
      ];
    });
  })
