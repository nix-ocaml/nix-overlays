{
  lib,
  binutils,
  stdenv,
  writeScriptBin,
}:

let
  fixOCaml =
    ocaml:
    (ocaml.override { useX11 = false; }).overrideAttrs (o: {
      dontUpdateAutotoolsGnuConfigScripts = true;
      dontDisableStatic = true;
      preConfigure = ''
        ${o.preConfigure or null}
        configureFlagsArray+=("PARTIALLD=$LD -r" "ASPP=$CC -c" "STRIP=''${STRIP:-strip}")
      ''
      + (
        if stdenv.hostPlatform.isMinGW then
          ''
            # For mingw/flexlink, use -static flag
            configureFlagsArray+=("MKEXE=flexlink -static" "MKDLL=flexlink -static" "MKMAINDLL=flexlink -static")
          ''
        else
          ''
            configureFlagsArray+=("LIBS=-static")
          ''
      );

      # For mingw static builds, modify the flexlink wrapper to use static mcfgthread
      postInstall =
        (o.postInstall or "")
        + lib.optionalString stdenv.hostPlatform.isMinGW ''
          # Replace dynamic -lmcfgthread with static -l:libmcfgthread.a in flexlink wrapper
          # Also add -lntdll which mcfgthread needs for NT kernel functions
          if [ -f $out/bin/flexlink.opt.exe ]; then
            sed -i 's/-lmcfgthread/-l:libmcfgthread.a -lntdll/g' $out/bin/flexlink.opt.exe
          fi
        '';
    });

  fixOCamlPackage =
    b:
    b.overrideAttrs (o: {
      # Static doesn't propagate `checkInputs` so we don't run the tests here
      doCheck = false;
    });
in

oself: osuper:

lib.mapAttrs (_: p: if p ? overrideAttrs then fixOCamlPackage p else p) osuper
// {
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
