{ lib }:
let
  fixOCaml = ocaml:
    (ocaml.override { useX11 = false; }).overrideAttrs (o: {
      dontUpdateAutotoolsGnuConfigScripts = true;
      dontDisableStatic = true;
      preConfigure = ''
        ${o.preConfigure or null}
        configureFlagsArray+=("PARTIALLD=$LD -r" "ASPP=$CC -c" "LIBS=-static")
      '';
    });

  fixOCamlPackage = b:
    b.overrideAttrs (o: {
      # Static doesn't propagate `checkInputs` so we don't run the tests here
      doCheck = false;
    });
in

oself: osuper:

lib.mapAttrs
  (_: p:
    if p ? overrideAttrs then
      fixOCamlPackage p
    else p)
  osuper // {
  ocaml = fixOCaml osuper.ocaml;

  kafka = osuper.kafka.overrideAttrs (o: {
    PKG_CONFIG_ARGN = "--static";
  });

  postgresql = osuper.postgresql.overrideAttrs (o: {
    PKG_CONFIG_ARGN = "--static";
  });

  zarith = osuper.zarith.overrideDerivation (o: {
    configureFlags = o.configureFlags ++ [
      "-prefixnonocaml ${o.stdenv.hostPlatform.config}-"
    ];
  });
}
