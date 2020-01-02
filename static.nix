{ pkgsPath ? <nixpkgs>, ocamlVersion ? "4_09" }:

let
  pkgsNative = import pkgsPath {};
  inherit (pkgsNative) lib;
  fixOcaml = ocaml:
    ((ocaml.override { useX11 = false; }).overrideAttrs (o: {
      configurePlatforms = [ ];
      dontUpdateAutotoolsGnuConfigScripts = true;
    })).overrideDerivation (o:
      if o.stdenv.hostPlatform != o.stdenv.buildPlatform then {
        # "LIBS=-static"
        preConfigure = ''
          configureFlagsArray+=("CC=$CC" "AS=$AS"  "PARTIALLD=$LD -r")
        '';
        configureFlags = (lib.remove "--no-shared-libs" o.configureFlags) ++ [
          "--disable-shared"
          "-host ${o.stdenv.hostPlatform.config} -target ${o.stdenv.targetPlatform.config}"
        ];
      } else
        { });
  fixOcamlBuild = b:
    b.overrideAttrs (o: {
      configurePlatforms = [ ];
      nativeBuildInputs = o.buildInputs;
    });
  pkgs = import pkgsPath {
    crossSystem = lib.systems.examples.musl64;
    overlays = [
      (self: super: { ocaml = fixOcaml super.ocaml; })
      (self: super: {
        opaline = fixOcamlBuild (super.opaline.override {
          ocamlPackages = self.ocaml-ng."ocamlPackages_${ocamlVersion}";
        });

        openssl = (super.openssl_1_1.override { static = true; }).overrideDerivation (o: {
          configureFlags =
            (lib.remove "--enable-static"
            (lib.remove "--disable-shared" o.configureFlags)) ++ [ "no-shared" ];
        });

        ocaml-ng = super.ocaml-ng // {
          "ocamlPackages_${ocamlVersion}" = (super.ocaml-ng."ocamlPackages_${ocamlVersion}".overrideScope'
            (oself: osuper: {
              ocaml = fixOcaml osuper.ocaml;
              findlib = fixOcamlBuild osuper.findlib;
              ocamlbuild = fixOcamlBuild osuper.ocamlbuild;
              buildDunePackage = args:
                fixOcamlBuild (osuper.buildDunePackage args);
              buildDune2Package = args:
                fixOcamlBuild (osuper.buildDunePackage (args // { dune = oself.dune_2; }));
              result = fixOcamlBuild osuper.result;
              zarith = (osuper.zarith.overrideAttrs (o: {
                configurePlatforms = [ ];
                nativeBuildInputs = o.nativeBuildInputs ++ o.buildInputs;
              })).overrideDerivation (o: {
                preConfigure = ''
                  echo $configureFlags
                '';
                configureFlags = o.configureFlags ++ [
                  "-host ${o.stdenv.hostPlatform.config} -prefixnonocaml ${o.stdenv.hostPlatform.config}-"
                ];
              });
              # ocamlgraph = fixOcamlBuild osuper.ocamlgraph;
              # easy-format = fixOcamlBuild osuper.easy-format;
              qcheck = fixOcamlBuild osuper.qcheck;
              stringext = fixOcamlBuild osuper.stringext;
              opam-file-format = fixOcamlBuild osuper.opam-file-format;
              bigstringaf = fixOcamlBuild osuper.bigstringaf;
              camlzip = fixOcamlBuild osuper.camlzip;
              dune = fixOcamlBuild osuper.dune;
              dune_2 = fixOcamlBuild osuper.dune_2;
              # digestif = fixOcamlBuild osuper.digestif;
              astring = fixOcamlBuild osuper.astring;
              rresult = fixOcamlBuild osuper.rresult;
              fpath = fixOcamlBuild osuper.fpath;
              # ocb-stubblr = fixOcamlBuild osuper.ocb-stubblr;
              cppo = fixOcamlBuild osuper.cppo;
              ocplib-endian = fixOcamlBuild osuper.ocplib-endian;
              ssl = fixOcamlBuild osuper.ssl;
            }
            )).overrideScope' (super.callPackage ./ocaml.nix { });
        };
      })
    ];
  };
in
  pkgs
