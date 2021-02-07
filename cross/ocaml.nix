{ lib, buildPackages, writeText, stdenv }:

oself: osuper:
let
  version = lib.stringAsChars
    (x: if x == "." then "_" else x)
    (builtins.substring 0 4 osuper.ocaml.version);
  natocamlPackages = buildPackages.ocaml-ng."ocamlPackages_${version}";
  natocaml = natocamlPackages.ocaml;
  fixOCaml = ocaml: ocaml.overrideAttrs (o:
    {
      preConfigure = ''
        configureFlagsArray+=("CC=$CC" "PARTIALLD=$LD -r" "ASPP=$CC -c" "AS=$AS")
      '';
      configureFlags = o.configureFlags ++ [
        "--disable-ocamldoc"
        "--disable-debugger"
      ];
      preBuild = ''
        buildFlagsArray+=("OCAMLYACC=${natocaml}/bin/ocamlyacc" "CAMLYACC=${natocaml}/bin/ocamlyacc" "CAMLRUN=${natocaml}/bin/ocamlrun" "OCAMLRUN=${natocaml}/bin/ocamlrun" -j16)
      '';
      buildPhase = ''
        runHook preBuild
        make "''${buildFlagsArray[@]}" -j16 world
        make "''${buildFlagsArray[@]}" -j16 opt
        make "''${buildFlagsArray[@]}" -j16 opt compilerlibs/ocamlcommon.cmxa compilerlibs/ocamlbytecomp.cmxa compilerlibs/ocamloptcomp.cmxa

        runHook postBuild
      '';
      installTargets = o.installTargets ++ [ "installoptopt" ];
      postInstall = ''
        cp ${natocaml}/bin/ocamlrun $out/bin/ocamlrun
        cp ${natocaml}/bin/ocamllex $out/bin/ocamllex
        cp ${natocaml}/bin/ocamlyacc $out/bin/ocamlyacc
      '';
      patches = [ ./cross.patch ];
    });
  fixOCamlPackage = b:
    b.overrideAttrs (o: {
      # configureFlags = removeUnknownConfigureFlags (o.configureFlags or [ ]);
      # configurePlatforms = [ ];
      nativeBuildInputs = (o.nativeBuildInputs or [ ]) ++ (o.buildInputs or [ ]);
      # buildInputs = [ ];
    });

in
((lib.mapAttrs (_: p: if p ? overrideAttrs then fixOCamlPackage p else p)) osuper) // {
  ocaml = fixOCaml osuper.ocaml;

  dune-configurator = osuper.dune-configurator.overrideAttrs (o: {
    dontConfigure = true;
    nativeBuildInputs = o.buildInputs;
    # nativeBuildInputs = (with natocamlPackages; [ ocaml dune buildPackages.stdenv.cc ]) ++ (with oself; [ ocaml findlib ]);
  });

  cppo = natocamlPackages.cppo;
  dune_2 = natocamlPackages.dune_2;

  # buildDunePackage = { buildInputs ? [ ], ... }@args:
  # (osuper.buildDunePackage (args // { buildInputs = [ ]; })).overrideAttrs (o: {
  # # buildInputs =
  # nativeBuildInputs = buildInputs ++ (with oself;[ ocaml ]) ++ (with natocamlPackages; [ dune ]);
  # });

  findlib = osuper.findlib.overrideAttrs (o:
    let
      natfindlib = natocamlPackages.findlib;

      native_findlib_conf = with oself; writeText "findlib.conf" ''
        # destdir="/nix/store/4wsdsa80wgyk943aahjz5hqbaw8vj8ka-ocaml-findlib-1.8.1/lib/ocaml/4.12.0-beta1/site-lib"
        # path="${natfindlib}/lib/ocaml/${natocaml.version}/site-lib"
        # ldconf="ignore"
        stdlib = "${natocaml}/lib/ocaml"
        ocamlc = "${natocaml}/bin/ocamlc"
        ocamlopt = "${natocaml}/bin/ocamlopt"
        ocamlcp = "${natocaml}/bin/ocamlcp"
        ocamlmklib = "${natocaml}/bin/ocamlmklib"
        ocamlmktop = "${natocaml}/bin/ocamlmktop"
        ocamldoc = "${natocaml}/bin/ocamldoc"
        ocamldep = "${natocaml}/bin/ocamldep"
      '';

      aarch64_findlib_conf = with oself; writeText "aarch64.conf" ''
        path(aarch64) = "${ocaml}/lib"
        # ldconf(aarch64)="ignore"
        # destdir(aarch64) = "$OCAML_SECONDARY_COMPILER/lib"
        stdlib(aarch64) = "${ocaml}/lib/ocaml"
        ocamlc(aarch64) = "${ocaml}/bin/ocamlc"
        ocamlopt(aarch64) = "${ocaml}/bin/ocamlopt"
        ocamlcp(aarch64) = "${ocaml}/bin/ocamlcp"
        ocamlmklib(aarch64) = "${ocaml}/bin/ocamlmklib"
        ocamlmktop(aarch64) = "${ocaml}/bin/ocamlmktop"
        ocamldoc(aarch64) = "${ocaml}/bin/ocamldoc"
        ocamldep(aarch64) = "${ocaml}/bin/ocamldep"
      '';

      findlib_conf = stdenv.mkDerivation {
        pname = "findlib-conf";
        version = "0.0.1";
        unpackPhase = "true";

        dontBuild = true;
        installPhase = ''
          mkdir -p $out/findlib.conf.d
          ln -sf ${native_findlib_conf} $out/findlib.conf
          ln -sf ${aarch64_findlib_conf} $out/findlib.conf.d/aarch64.conf
          # ln -sf ${natfindlib}/etc/findlib.conf $out/findlib.conf.d/findlib.conf
        '';
      };
    in
    {
      configurePlatforms = [ ];

      nativeBuildInputs = with buildPackages; [
        m4
        ncurses
        ocaml
        buildPackages.stdenv.cc
      ];

      setupHook = writeText "setupHook.sh" ''
        addOCamlPath () {
            echo AHOY "$1"
            if test -d "''$1/lib/ocaml/${natocaml.version}/site-lib"; then
                export OCAMLPATH="''${OCAMLPATH-}''${OCAMLPATH:+:}''$1/lib/ocaml/${natocaml.version}/site-lib/"
            fi
            if test -d "''$1/lib/ocaml/${natocaml.version}/site-lib/stublibs"; then
                export CAML_LD_LIBRARY_PATH="''${CAML_LD_LIBRARY_PATH-}''${CAML_LD_LIBRARY_PATH:+:}''$1/lib/ocaml/${natocaml.version}/site-lib/stublibs"
            fi
            export OCAMLFIND_DESTDIR="''$out/lib/ocaml/${natocaml.version}/site-lib/"
            if test -n "''${createFindlibDestdir-}"; then
              mkdir -p $OCAMLFIND_DESTDIR
            fi
            export OCAMLFIND_CONF="${findlib_conf}/findlib.conf";
        }

        addEnvHooks "$targetOffset" addOCamlPath
      '';
    });

  lwt = osuper.lwt.overrideAttrs (o: {
    nativeBuildInputs =
      (with natocamlPackages; [ cppo dune ]) ++ (with oself; [ ocaml findlib ]);
    buildInputs = with oself; [ ocaml-syntax-shims ];
  });

  ocaml-migrate-parsetree = osuper.ocaml-migrate-parsetree.overrideAttrs (o: {
    buildInputs = [ ];
    nativeBuildInputs = (with natocamlPackages; [
      ocaml
      dune
      buildPackages.stdenv.cc
    ]) ++ (with oself; [ findlib ]);
  });
}
