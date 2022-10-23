{ lib }:
let
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

  postgresql = osuper.postgresql.overrideAttrs (o: {
    patches = [ ./postgresql_static.patch ];
  });

  zarith = osuper.zarith.overrideDerivation (o: {
    configureFlags = o.configureFlags ++ [
      "-prefixnonocaml ${o.stdenv.hostPlatform.config}-"
    ];
  });
}
