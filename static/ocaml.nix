{ lib, binutils, stdenv, writeScriptBin }:
let
  fixOCaml = ocaml:
    (ocaml.override { useX11 = false; }).overrideAttrs (o:
      let
        strip-script =
          let
            strip-pkg =
              if stdenv.cc.targetPrefix == ""
              then "${binutils}/bin/strip"
              else "${stdenv.cc.targetPrefix}strip";
          in
          writeScriptBin "strip" ''
            #!${stdenv.shell}
            ${strip-pkg} $@
          '';
      in
      {
        nativeBuildInputs = (o.nativeBuildInputs or [ ]) ++ [ strip-script ];
        # buildInputs = (o.buildInputs) ++ [ binutils ];
        dontUpdateAutotoolsGnuConfigScripts = true;
        dontDisableStatic = true;
        preConfigure = ''
          ${o.preConfigure or null}
          configureFlagsArray+=("PARTIALLD=$LD -r" "ASPP=$CC -c" "LIBS=-static" "STRIP=''${STRIP:strip}")
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
