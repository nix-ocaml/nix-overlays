# Note to the future reader:
#
# As opposed to the other overlays, this one effectively virtualizes an opam
# switch. Dune is particular in how it finds its dependencies across build /
# host platforms, and emulating an opam switch layout makes it work seamlessly.
#
# The only obvious downside is that there can only be one of each, even at
# build time (e.g. OMP / ppxlib, etc that are possible to allow in the other
# overlays).

{ lib, buildPackages, writeText, stdenv, bash }:
let mergeInputs = names: attrs:
  let ret =
    builtins.filter
      lib.isDerivation
      (lib.concatLists
        (builtins.map
          (name:
            lib.concatLists (lib.catAttrs name attrs))
          names));
  in
  if ret == [ ] then [ ] else
  lib.unique (ret ++ (mergeInputs names ret));

in
[
  (oself: osuper:
    let
      crossName = stdenv.hostPlatform.parsed.cpu.name;
      version = lib.stringAsChars
        (x: if x == "." then "_" else x)
        (builtins.substring 0 4 osuper.ocaml.version);
      natocamlPackages = buildPackages.ocaml-ng."ocamlPackages_${version}";
      natocaml = natocamlPackages.ocaml;
    in
    {
      dune-configurator = osuper.dune-configurator.overrideAttrs (o: {
        configurePlatforms = [ ];
      });

      buildDunePackage = args:
        (osuper.buildDunePackage args).overrideAttrs (o: {
          nativeBuildInputs = (o.nativeBuildInputs or [ ]) ++
            (with natocamlPackages; [ ocaml buildPackages.stdenv.cc ]);

          buildPhase = ''
            runHook preBuild
            dune build -p ${o.pname} ''${enableParallelBuilding:+-j $NIX_BUILD_CORES} --display=short -x ${crossName}
            runHook postBuild
          '';

          installPhase =
            let
              natPackage = natocamlPackages."${o.pname}";
            in
            ''
              runHook preInstall
              ${buildPackages.opaline}/bin/opaline -name ${o.pname} -prefix $out -libdir $OCAMLFIND_DESTDIR

              rm -rf $out/lib/ocaml/${osuper.ocaml.version}/site-lib
              cp -r ${natPackage}/lib/ocaml/${osuper.ocaml.version}/site-lib $out/lib/ocaml/${osuper.ocaml.version}/site-lib
              runHook postInstall
            '';
        });

      camlzip = osuper.camlzip.overrideAttrs (_: {
        OCAMLFIND_TOOLCHAIN = "${crossName}";
        postInstall = ''
          ln -s $out/lib/ocaml/${osuper.ocaml.version}/site-lib/{,caml}zip

          OCAMLFIND_DESTDIR=$(dirname $OCAMLFIND_DESTDIR)/${crossName}-sysroot/lib/
          mkdir -p $OCAMLFIND_DESTDIR
          mv $out/lib/ocaml/${osuper.ocaml.version}/site-lib/* $OCAMLFIND_DESTDIR
        '';
      });

      carl = osuper.carl.overrideAttrs (o: {
        OCAMLFIND_TOOLCHAIN = "${crossName}";
      });

      menhir = osuper.menhir.overrideAttrs (o: {
        postInstall = ''
          cp -r ${natocamlPackages.menhir}/bin/* $out/bin
        '';
      });

      num = osuper.num.overrideAttrs (_: {
        OCAMLFIND_TOOLCHAIN = "${crossName}";
        postInstall = ''
          OCAMLFIND_DESTDIR=$(dirname $OCAMLFIND_DESTDIR)/${crossName}-sysroot/lib/
          mkdir -p $OCAMLFIND_DESTDIR
          mv $out/lib/ocaml/${osuper.ocaml.version}/site-lib/* $OCAMLFIND_DESTDIR
        '';
      });

      ocaml-migrate-parsetree = oself.ocaml-migrate-parsetree-2-1;

      seq = osuper.seq.overrideAttrs (_: {
        installPhase = ''
          install_dest="$out/lib/ocaml/${osuper.ocaml.version}/${crossName}-sysroot/lib/seq/"
          mkdir -p $install_dest
          cp META $install_dest
        '';
      });

      uchar = osuper.uchar.overrideAttrs (_: {
        installPhase = oself.topkg.installPhase;
      });

      zarith = osuper.zarith.overrideAttrs (o: {
        configurePlatforms = [ ];
        OCAMLFIND_TOOLCHAIN = "${crossName}";
        configureFlags = o.configureFlags ++ [
          "-prefixnonocaml ${stdenv.cc.targetPrefix}"
        ];
        preBuild = ''
          buildFlagsArray+=("host=${stdenv.hostPlatform.config}")
        '';
        postInstall = ''
          OCAMLFIND_DESTDIR=$(dirname $OCAMLFIND_DESTDIR)/${crossName}-sysroot/lib/
          mkdir -p $OCAMLFIND_DESTDIR
          mv $out/lib/ocaml/${osuper.ocaml.version}/site-lib/* $OCAMLFIND_DESTDIR
        '';
      });

    })

  (oself: osuper:
    let
      crossName = lib.head (lib.splitString "-" stdenv.system);
      version = lib.stringAsChars
        (x: if x == "." then "_" else x)
        (builtins.substring 0 4 osuper.ocaml.version);
      natocamlPackages = buildPackages.ocaml-ng."ocamlPackages_${version}";
      natocaml = natocamlPackages.ocaml;
      natfindlib = natocamlPackages.findlib;
      fixOCaml = ocaml: ocaml.overrideAttrs (o:
        {
          nativeBuildInputs = [ buildPackages.stdenv.cc ];
          buildInputs = o.buildInputs;
          preConfigure = ''
            configureFlagsArray+=("PARTIALLD=$LD -r" "ASPP=$CC -c")
          '';

          buildPhase = ''
            runHook preBuild
            buildFlagsArray+=("OCAMLYACC=${natocaml}/bin/ocamlyacc" "CAMLYACC=${natocaml}/bin/ocamlyacc" "CAMLRUN=${natocaml}/bin/ocamlrun" "OCAMLRUN=${natocaml}/bin/ocamlrun" -j16)

            write_wrapper () {
              TARGET="$1"
              RUN="$2"

              ARGS='for ARG in "$@"; do NEW_ARGS="$NEW_ARGS \"$ARG\""; done'

              if [[ "$(uname)" != 'Linux' ]]; then
                ARGS='
            for ARG in "$@"
            do
              if (
                [ "$ARG" != "-function-sections" ]
              ); then
                NEW_ARGS="$NEW_ARGS \"$ARG\""
              fi
            done'
              fi

            cat > $TARGET <<EOF
            #!${bash}/bin/bash
            NEW_ARGS=""
            $ARGS
            eval "$RUN \$NEW_ARGS"
            EOF

              chmod +x $TARGET
            }

            OCAML_HOST=${natocaml}
            OCAMLRUN="$OCAML_HOST/bin/ocamlrun"
            OCAMLYACC="$OCAML_HOST/bin/ocamlyacc"
            CAMLDEP="$OCAML_HOST/bin/ocamlc"
            DYNAMIC_LIBS="-I $OCAML_HOST/lib/ocaml/stublibs"
            HOST_STATIC_LIBS="-I $OCAML_HOST/lib/ocaml"
            TARGET_STATIC_LIBS="-I $PWD/stdlib -I $PWD/otherlibs/unix"

            HOST_MAKEFILE_CONFIG="$OCAML_HOST/lib/ocaml/Makefile.config"
            get_host_variable () {
              cat $HOST_MAKEFILE_CONFIG | grep "$1=" | awk -F '=' '{print $2}'
            }

            NATDYNLINK=$(get_host_variable "NATDYNLINK")
            NATDYNLINKOPTS=$(get_host_variable "NATDYNLINKOPTS")


            make_caml () {
              write_wrapper "$PWD/ocamlc.wrapper" "$CAMLC"
              write_wrapper "$PWD/ocamlopt.wrapper" "$CAMLOPT"

              CAMLC="$PWD/ocamlc.wrapper"
              CAMLOPT="$PWD/ocamlopt.wrapper"

              make CAMLDEP="$CAMLDEP -depend" \
                OCAMLYACC="$OCAMLYACC" CAMLYACC="$OCAMLYACC" \
                CAMLRUN="$OCAMLRUN" OCAMLRUN="$OCAMLRUN" \
                CAMLC="$CAMLC" OCAMLC="$CAMLC" \
                CAMLOPT="$CAMLOPT" OCAMLOPT="$CAMLOPT" \
                $@
            }

            make_host () {
              CAMLC="$OCAML_HOST/bin/ocamlc.opt $HOST_STATIC_LIBS $DYNAMIC_LIBS -nostdlib"
              CAMLOPT="$OCAML_HOST/bin/ocamlopt.opt $HOST_STATIC_LIBS -nostdlib"

              make_caml \
                NATDYNLINK="$NATDYNLINK" NATDYNLINKOPTS="$NATDYNLINKOPTS" \
                $@
            }


            # Target
            make_target () {
              CAMLC="$PWD/ocamlc.opt $TARGET_STATIC_LIBS $DYNAMIC_LIBS -nostdlib"
              CAMLOPT="$PWD/ocamlopt.opt $TARGET_STATIC_LIBS -nostdlib"

            make_caml $@

            }

            make_host -j8 runtime coreall
            make_host -j8 opt-core
            make_host -j8 ocamlc.opt ocamlopt.opt
            make_host -j8 ocamldoc compilerlibs/ocamltoplevel.cma otherlibraries ocamldebugger
            make_host -j8 ocamllex.opt ocamltoolsopt ocamltoolsopt.opt ocamldoc.opt

            rm $(find . | grep -e '\.cm.$')
            make_target -j8 -C stdlib all allopt
            make_target ocaml ocamlc ocamlopt
            make_target -j8 otherlibraries otherlibrariesopt ocamltoolsopt
            make_target -j8 driver/main.cmx driver/optmain.cmx \
              compilerlibs/ocamlcommon.cmxa \
              compilerlibs/ocamlbytecomp.cmxa \
              compilerlibs/ocamloptcomp.cmxa
            make_target -j8 -C ocamldoc all allopt

            runHook postBuild
          '';
          installTargets = o.installTargets ++ [ "installoptopt" ];
          patches = [
            (if lib.versionOlder "4.12" ocaml.version then ./cross_4_12.patch
            else if lib.versionOlder "4.12" ocaml.version then ./cross_4_11.patch else
            throw "OCaml ${ocaml.version} not supported for cross-compilation")
          ];
        });
      fixOCamlPackage = b:
        let
          inputs = mergeInputs [
            "propagatedBuildInputs"
            "buildInputs"
            "nativeBuildInputs"
          ] [ b ];
          natInputs = mergeInputs [
            "propagatedBuildInputs"
            "buildInputs"
            "nativeBuildInputs"
          ] [ b ];

          path =
            builtins.concatStringsSep ":"
              (builtins.map (x: "${x.outPath}/lib/ocaml/${natocaml.version}/${crossName}-sysroot/lib")
                inputs);
          natPath =
            builtins.concatStringsSep ":"
              (builtins.map (x: "${x.outPath}/lib/ocaml/${natocaml.version}/site-lib")
                natInputs);

          native_findlib_conf =
            writeText "${b.name}-findlib.conf" ''
              path="${natfindlib}/lib/ocaml/${natocaml.version}/site-lib:${natPath}"
              ldconf="ignore"
              stdlib = "${natocaml}/lib/ocaml"
              ocamlc = "${natocaml}/bin/ocamlc"
              ocamlopt = "${natocaml}/bin/ocamlopt"
              ocamlcp = "${natocaml}/bin/ocamlcp"
              ocamlmklib = "${natocaml}/bin/ocamlmklib"
              ocamlmktop = "${natocaml}/bin/ocamlmktop"
              ocamldoc = "${natocaml}/bin/ocamldoc"
              ocamldep = "${natocaml}/bin/ocamldep"
            '';

          aarch64_findlib_conf = with oself; writeText "${b.name}-${crossName}.conf" ''
            path(${crossName}) = "${findlib}/lib/ocaml/${ocaml.version}/site-lib:${path}"
            ldconf(${crossName})="ignore"
            stdlib(${crossName}) = "${ocaml}/lib/ocaml"
            ocamlc(${crossName}) = "${ocaml}/bin/ocamlc"
            ocamlopt(${crossName}) = "${ocaml}/bin/ocamlopt"
            ocamlcp(${crossName}) = "${ocaml}/bin/ocamlcp"
            ocamlmklib(${crossName}) = "${ocaml}/bin/ocamlmklib"
            ocamlmktop(${crossName}) = "${ocaml}/bin/ocamlmktop"
            ocamldoc(${crossName}) = "${ocaml}/bin/ocamldoc"
            ocamldep(${crossName}) = "${ocaml}/bin/ocamldep"
          '';

          findlib_conf = stdenv.mkDerivation {
            name = "${b.name}-findlib-conf";
            version = "0.0.1";
            unpackPhase = "true";

            dontBuild = true;
            installPhase = ''
              mkdir -p $out/findlib.conf.d
              ln -sf ${native_findlib_conf} $out/findlib.conf
              ln -sf ${aarch64_findlib_conf} $out/findlib.conf.d/${crossName}.conf
            '';
          };

        in
        b.overrideAttrs (o: {
          nativeBuildInputs = (o.nativeBuildInputs or [ ]) ++ (o.buildInputs or [ ]);
          OCAMLFIND_CONF = "${findlib_conf}/findlib.conf";
        });

    in
    (lib.mapAttrs (_: p: if p ? overrideAttrs then fixOCamlPackage p else p) osuper) // {
      ocaml = fixOCaml osuper.ocaml;

      findlib = osuper.findlib.overrideAttrs (o: {
        configurePlatforms = [ ];

        nativeBuildInputs = with buildPackages; [
          m4
          ncurses
          natocaml
          buildPackages.stdenv.cc
        ];

        setupHook = writeText "setupHook.sh" ''
          addOCamlPath () {
            export OCAMLFIND_DESTDIR="''$out/lib/ocaml/${osuper.ocaml.version}/site-lib/"
            if test -n "''${createFindlibDestdir-}";
            then
              mkdir -p $OCAMLFIND_DESTDIR
            fi
          }

          addEnvHooks "$targetOffset" addOCamlPath
        '';
      });

      cppo = natocamlPackages.cppo;
      dune_2 = natocamlPackages.dune_2;
      dune = natocamlPackages.dune_2;
      ocamlbuild = osuper.ocamlbuild.overrideAttrs (o: {
        buildInputs = [ oself.findlib ];
        propagatedNativeBuildInputs = [ buildPackages.stdenv.cc ];
        propagatedBuildInputs = [ buildPackages.stdenv.cc ];
        nativeBuildInputs = [ natfindlib natocaml ];
      });

      topkg = osuper.topkg.overrideAttrs (o:
        let run = "${natocaml}/bin/ocaml -I ${natfindlib}/lib/ocaml/${osuper.ocaml.version}/site-lib/ pkg/pkg.ml";
        in
        {
          selfBuild = true;
          buildPhase = "${run} build";
          passthru = {
            inherit run;
          };
          installPhase = ''
            if [ -z "''${selfBuild:-}" ]; then
              OCAMLFIND_DESTDIR=$(dirname $OCAMLFIND_DESTDIR)/${crossName}-sysroot/lib/
            fi
            ${buildPackages.opaline}/bin/opaline -prefix $out -libdir $OCAMLFIND_DESTDIR
          '';
          buildInputs = (with oself; [ ocaml ]);

          nativeBuildInputs = (with natocamlPackages; [ ocaml ]) ++
          (with oself; [ ocamlbuild findlib buildPackages.stdenv.cc ]);

          setupHook = writeText "setupHook.sh" ''
            addToolchainVariable () {
              if [ -z "''${selfBuild:-}" ]; then
                export TOPKG_CONF_TOOLCHAIN="${crossName}"
              fi
            }

            addEnvHooks "$targetOffset" addToolchainVariable
          '';
        });
    })
]
