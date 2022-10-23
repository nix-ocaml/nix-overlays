# Note to the future reader:
#
# As opposed to the other overlays, this one effectively virtualizes an opam
# switch. Dune is particular in how it finds its dependencies across build /
# host platforms, and emulating an opam switch layout makes it work seamlessly.
#
# The only obvious downside is that there can only be one of each, even at
# build time (e.g. OMP / ppxlib, etc that are possible to allow in the other
# overlays).

{ lib, buildPackages, writeText, writeScriptBin, stdenv, bash }:
let
  __mergeInputs = acc: names: attrs:
    let
      ret =
        lib.foldl' (acc: x: acc // { "${x.name}" = x; })
          { }
          (builtins.concatMap
            (name:
              builtins.filter
                lib.isDerivation
                (lib.concatLists (lib.catAttrs name attrs)))
            names);
    in
    if ret == { } then acc
    else
      __mergeInputs (acc // ret) names (lib.attrValues ret);

  mergeInputs = names: attrs:
    let acc = __mergeInputs { } names [ attrs ];
    in
    lib.attrValues acc;

  getNativeOCamlPackages = osuper:
    let
      version =
        if lib.hasPrefix "5." osuper.ocaml.version
        then "5_0"
        else
          lib.stringAsChars
            (x: if x == "." then "_" else x)
            (builtins.substring 0 4 osuper.ocaml.version);

    in
    buildPackages.ocaml-ng."ocamlPackages_${version}";
in
[
  (oself: osuper:
    let
      crossName = stdenv.hostPlatform.parsed.cpu.name;
      natocamlPackages = getNativeOCamlPackages osuper;
      natocaml = natocamlPackages.ocaml;
      natdune = natocamlPackages.dune;
      natfindlib = natocamlPackages.findlib;
      fixTopkgInstall = p: natPackage: p.overrideAttrs (o: {
        installPhase = ''
          rm -rf $out/lib/ocaml/${osuper.ocaml.version}/site-lib
          mkdir -p $out/lib/ocaml/${osuper.ocaml.version}
          ln -sfn ${natPackage}/lib/ocaml/${osuper.ocaml.version}/site-lib $out/lib/ocaml/${osuper.ocaml.version}/site-lib

          ${o.installPhase}
          runHook postInstall
        '';
      });

    in
    {
      makeFindlibConf = b:
        let
          inputs = mergeInputs [
            "propagatedBuildInputs"
            "buildInputs"
            "checkInputs"
          ]
            b;
          natInputs = mergeInputs [
            "propagatedBuildInputs"
            "nativeBuildInputs"
          ]
            b;

          path =
            builtins.concatStringsSep ":"
              (builtins.map (x: "${x.outPath}/lib/ocaml/${natocaml.version}/${crossName}-sysroot/lib")
                inputs);
          natPath =
            builtins.concatStringsSep ":"
              (builtins.map (x: "${x.outPath}/lib/ocaml/${natocaml.version}/site-lib")
                natInputs);

          native_findlib_conf =
            writeText "${b.name or b.pname}-findlib.conf" ''
              path="${natocaml}/lib/ocaml:${natfindlib}/lib/ocaml/${natocaml.version}/site-lib:${natPath}"
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

          aarch64_findlib_conf =
            let inherit (oself) ocaml findlib; in
            writeText "${b.name or b.pname}-${crossName}.conf" ''
              path(${crossName}) = "${ocaml}/lib/ocaml:${findlib}/lib/ocaml/${ocaml.version}/site-lib:${path}"
              ldconf(${crossName})="ignore"
              stdlib(${crossName}) = "${ocaml}/lib/ocaml"
              ocamlc(${crossName}) = "${ocaml}/bin/ocamlc"
              ocamlopt(${crossName}) = "${ocaml}/bin/ocamlopt"
              ocamlcp(${crossName}) = "${ocaml}/bin/ocamlcp"
              ocamlmklib(${crossName}) = "${ocaml}/bin/ocamlmklib"
              ocamlmktop(${crossName}) = "${ocaml}/bin/ocamlmktop"
              ocamldoc(${crossName}) = "${natocaml}/bin/ocamldoc"
              ocamldep(${crossName}) = "${ocaml}/bin/ocamldep"
            '';

          findlib_conf = stdenv.mkDerivation {
            name = "${b.name or b.pname}-findlib-conf";
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
        "${findlib_conf}/findlib.conf";

      buildDunePackage = args:
        (osuper.buildDunePackage (
          {

            OCAMLFIND_CONF = oself.makeFindlibConf args;
            buildPhase = ''
              runHook preBuild
              dune build -p ${args.pname} ''${enableParallelBuilding:+-j $NIX_BUILD_CORES} -x ${crossName}
              runHook postBuild
            '';

            installPhase =
              let
                natPackage =
                  natocamlPackages."${args.pname}" or
                    # Some legacy packages are called `ocaml_X`, e.g. extlib and
                    # sqlite3
                    natocamlPackages."ocaml_${args.pname}";
              in
              ''
                runHook preInstall
                ${oself.opaline}/bin/opaline -name ${args.pname} -prefix $out -libdir $OCAMLFIND_DESTDIR

                rm -rf $out/lib/ocaml/${osuper.ocaml.version}/site-lib
                ln -sfn ${natPackage}/lib/ocaml/${osuper.ocaml.version}/site-lib $out/lib/ocaml/${osuper.ocaml.version}/site-lib
                runHook postInstall
              '';

          } // args
        )).overrideAttrs (o: {
          nativeBuildInputs =
            [ natocaml natdune natfindlib buildPackages.stdenv.cc ] ++
            # XXX(anmonteiro): apparently important that this comes after
            (o.nativeBuildInputs or [ ]);

        });

      camlzip = osuper.camlzip.overrideAttrs (_: {
        OCAMLFIND_TOOLCHAIN = "${crossName}";
        postInstall = ''
          OCAMLFIND_DESTDIR=$(dirname $OCAMLFIND_DESTDIR)/${crossName}-sysroot/lib/
          mkdir -p $OCAMLFIND_DESTDIR
          mv $out/lib/ocaml/${osuper.ocaml.version}/site-lib/* $OCAMLFIND_DESTDIR
          rm -rf $OCAMLFIND_DESTDIR/camlzip
          ln -sfn $OCAMLFIND_DESTDIR/{,caml}zip
        '';
      });

      cmdliner = osuper.cmdliner.overrideAttrs (o: {
        nativeBuildInputs = o.nativeBuildInputs ++ [ oself.findlib ];

        installPhase = ''
          rm -rf $out/lib/ocaml/${osuper.ocaml.version}/site-lib
          mkdir -p $out/lib/ocaml/${osuper.ocaml.version}
          ln -sfn ${natocamlPackages.cmdliner}/lib/ocaml/${osuper.ocaml.version}/site-lib $out/lib/ocaml/${osuper.ocaml.version}/site-lib

          OCAMLFIND_DESTDIR=$(dirname $OCAMLFIND_DESTDIR)/${crossName}-sysroot/lib/
          mkdir -p $OCAMLFIND_DESTDIR
          make install LIBDIR=$OCAMLFIND_DESTDIR/cmdliner
        '';
      });

      afl-persistent = osuper.afl-persistent.overrideAttrs (o: {
        OCAMLFIND_TOOLCHAIN = "${crossName}";

        postPatch = ''
          ${o.postPatch}
          head -n -3 ./build.sh > ./temp.sh
          mv temp.sh build.sh
          chmod a+x ./build.sh
        '';
        installPhase = ''
          ${buildPackages.opaline}/bin/opaline -prefix $out -libdir $out/lib/ocaml/${osuper.ocaml.version}/site-lib/ ${o.pname}.install
          OCAMLFIND_DESTDIR=$(dirname $OCAMLFIND_DESTDIR)/${crossName}-sysroot/lib/
          mkdir -p $OCAMLFIND_DESTDIR
          mv $out/lib/ocaml/${osuper.ocaml.version}/site-lib/* $OCAMLFIND_DESTDIR
        '';
      });

      carl =
        if lib.versionAtLeast osuper.ocaml.version "5.0"
        then
          osuper.carl.overrideAttrs
            (o: {
              OCAMLFIND_TOOLCHAIN = "${crossName}";
            })
        else null;

      astring = fixTopkgInstall osuper.astring natocamlPackages.astring;
      jsonm = fixTopkgInstall osuper.jsonm natocamlPackages.jsonm;
      fmt = fixTopkgInstall osuper.fmt natocamlPackages.fmt;
      uutf = fixTopkgInstall osuper.uutf natocamlPackages.uutf;
      uunf = fixTopkgInstall osuper.uunf natocamlPackages.uunf;
      logs = fixTopkgInstall osuper.logs natocamlPackages.logs;
      fpath = fixTopkgInstall osuper.fpath natocamlPackages.fpath;
      bos = fixTopkgInstall osuper.bos natocamlPackages.bos;
      ptime = fixTopkgInstall osuper.ptime natocamlPackages.ptime;
      rresult = fixTopkgInstall osuper.rresult natocamlPackages.rresult;
      mtime = fixTopkgInstall osuper.mtime natocamlPackages.mtime;
      xmlm = fixTopkgInstall osuper.xmlm natocamlPackages.xmlm;

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

      ocaml-migrate-parsetree = oself.ocaml-migrate-parsetree-2;

      seq = osuper.seq.overrideAttrs (_: {
        installPhase = ''
          install_dest="$out/lib/ocaml/${osuper.ocaml.version}/${crossName}-sysroot/lib/seq/"
          mkdir -p $install_dest
          mv META $install_dest

          mkdir -p $out/lib/ocaml/${osuper.ocaml.version}/site-lib/seq
          ln -sfn $install_dest/META $out/lib/ocaml/${osuper.ocaml.version}/site-lib/seq
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

          rm -rf $out/lib/ocaml/${osuper.ocaml.version}/site-lib
          mkdir -p $out/lib/ocaml/${osuper.ocaml.version}
          ln -sfn ${natocamlPackages.zarith}/lib/ocaml/${osuper.ocaml.version}/site-lib $out/lib/ocaml/${osuper.ocaml.version}/site-lib
        '';
      });

    })

  (oself: osuper:
    let
      crossName = lib.head (lib.splitString "-" stdenv.system);
      natocamlPackages = getNativeOCamlPackages osuper;
      natocaml = natocamlPackages.ocaml;
      natfindlib = natocamlPackages.findlib;
      genWrapper = name: camlBin: writeScriptBin name ''
        #!${stdenv.shell}
        NEW_ARGS=""

        for ARG in "$@"; do NEW_ARGS="$NEW_ARGS \"$ARG\""; done
        eval "${camlBin} $NEW_ARGS"
      '';
      ocamlcHostWrapper = genWrapper "ocamlcHost.wrapper" "${natocaml}/bin/ocamlc.opt -I ${natocaml}/lib/ocaml -I ${natocaml}/lib/ocaml/stublibs -I +unix -nostdlib ";
      ocamloptHostWrapper = genWrapper "ocamloptHost.wrapper" "${natocaml}/bin/ocamlopt.opt -I ${natocaml}/lib/ocaml -I +unix -nostdlib ";

      ocamlcTargetWrapper = genWrapper "ocamlcTarget.wrapper" "$BUILD_ROOT/ocamlc.opt -I $BUILD_ROOT/stdlib -I $BUILD_ROOT/otherlibs/unix -I ${natocaml}/lib/ocaml/stublibs -nostdlib ";
      ocamloptTargetWrapper = genWrapper "ocamloptTarget.wrapper" "$BUILD_ROOT/ocamlopt.opt -I $BUILD_ROOT/stdlib -I $BUILD_ROOT/otherlibs/unix -nostdlib ";

      fixOCaml = ocaml: ocaml.overrideAttrs (o:
        let isOCaml5 = lib.versionOlder "5.0" ocaml.version;
        in
        {
          nativeBuildInputs = [ buildPackages.stdenv.cc ];
          preConfigure = ''
            configureFlagsArray+=("PARTIALLD=$LD -r" "ASPP=$CC -c")
          '';
          configureFlags = o.configureFlags ++ [ "--disable-ocamldoc" ];
          postConfigure = ''
            echo 'SAK_CC=${buildPackages.stdenv.cc}/bin/gcc' >> Makefile.config
            echo 'SAK_CFLAGS=$(OC_CFLAGS) $(OC_CPPFLAGS)' >> Makefile.config
            echo 'SAK_LINK=$(SAK_CC) $(SAK_CFLAGS) $(OUTPUTEXE)$(1) $(2)' >> Makefile.config
          '';

          buildPhase = ''
            runHook preBuild

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
              make ''${enableParallelBuilding:+-j $NIX_BUILD_CORES} ''${enableParallelBuilding:+-l $NIX_BUILD_CORES} \
                   CAMLDEP="$CAMLDEP -depend" \
                   OCAMLYACC="$OCAMLYACC" CAMLYACC="$OCAMLYACC" \
                   CAMLRUN="$OCAMLRUN" OCAMLRUN="$OCAMLRUN" \
                   NEW_OCAMLRUN="$OCAMLRUN" \
                   CAMLC="$CAMLC" OCAMLC="$CAMLC" \
                   CAMLOPT="$CAMLOPT" OCAMLOPT="$CAMLOPT" \
                   $@
            }

            make_host () {
              CAMLC="${ocamlcHostWrapper}/bin/ocamlcHost.wrapper"
              CAMLOPT="${ocamloptHostWrapper}/bin/ocamloptHost.wrapper"

              make_caml \
                NATDYNLINK="$NATDYNLINK" NATDYNLINKOPTS="$NATDYNLINKOPTS" \
                "$@"
            }

            make_target () {
              CAMLC="${ocamlcTargetWrapper}/bin/ocamlcTarget.wrapper"
              CAMLOPT="${ocamloptTargetWrapper}/bin/ocamloptTarget.wrapper"

              make_caml BUILD_ROOT="$PWD" TARGET_OCAMLC="$TARGET_OCAMLC" TARGET_OCAMLOPT="$TARGET_OCAMLOPT" "$@"
            }

            make_host runtime coreall
            make_host opt-core
            make_host ocamlc.opt
            make_host ocamlopt.opt
            make_host compilerlibs/ocamltoplevel.cma otherlibraries \
                      ocamldebugger
            make_host ocamllex.opt ocamltoolsopt \
                      ocamltoolsopt.opt ${if isOCaml5 then "othertools" else ""}

            rm $(find . | grep -E '\.cm.?.$')
            make_target -C stdlib all allopt
            make_target ocaml ocamlc
            make_target ocamlopt otherlibraries \
                        otherlibrariesopt ocamltoolsopt \
                        driver/main.cmx driver/optmain.cmx \
                        compilerlibs/ocamlcommon.cmxa \
                        compilerlibs/ocamlbytecomp.cmxa \
                        compilerlibs/ocamloptcomp.cmxa
            ${if isOCaml5 then "make_target othertools" else ""}

            runHook postBuild
          '';
          installTargets = o.installTargets ++ [ "installoptopt" ];
          patches = [
            (if isOCaml5
            then ./cross_5_00.patch
            else if lib.versionOlder "4.14" ocaml.version
            then ./cross_4_14.patch
            else if lib.versionOlder "4.13" ocaml.version
            then ./cross_4_13.patch
            else if lib.versionOlder "4.12" ocaml.version
            then ./cross_4_12.patch
            else if lib.versionOlder "4.11" ocaml.version
            then ./cross_4_11.patch
            else throw "OCaml ${ocaml.version} not supported for cross-compilation")
          ];
        });
      fixOCamlPackage = b:
        b.overrideAttrs (o: {
          OCAMLFIND_CONF = oself.makeFindlibConf b;
        });

    in
    (lib.mapAttrs (_: p: if p ? overrideAttrs then fixOCamlPackage p else p) osuper) // {
      ocaml = fixOCaml osuper.ocaml;

      findlib = osuper.findlib.overrideAttrs (o: {
        postInstall = ''
          rm -rf $out/bin/ocamlfind
          cp ${natfindlib}/bin/ocamlfind $out/bin/ocamlfind
        '';
      });

      ctypes = (fixOCamlPackage osuper.ctypes).overrideAttrs (o: {
        postInstall = ''
          echo -e '\nversion = "${o.version}"'>> $out/lib/ocaml/${osuper.ocaml.version}/aarch64-sysroot/lib/ctypes/META
        '';
      });

      cppo = natocamlPackages.cppo;
      dune_2 = natocamlPackages.dune;
      dune_3 = natocamlPackages.dune;
      dune = natocamlPackages.dune;

      ocamlbuild = natocamlPackages.ocamlbuild.overrideAttrs (o: {
        propagatedBuildInputs = [ buildPackages.stdenv.cc ];
      });

      opaline = natocamlPackages.opaline;

      topkg = natocamlPackages.topkg.overrideAttrs (o:
        let
          run = ''
            if [ -z "''${selfBuild:-}" ]; then
              unset OCAMLPATH
            fi

            ${natocaml}/bin/ocaml -I ${natfindlib}/lib/ocaml/${osuper.ocaml.version}/site-lib/ pkg/pkg.ml \
          '';
        in
        {
          selfBuild = true;

          passthru = {
            inherit run;
          };

          buildPhase = "${run} build";

          installPhase = ''
            if [ -z "''${selfBuild:-}" ]; then
              OCAMLFIND_DESTDIR=$(dirname $OCAMLFIND_DESTDIR)/${crossName}-sysroot/lib/
            fi
            ${oself.opaline}/bin/opaline -prefix $out -libdir $OCAMLFIND_DESTDIR
          '';

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
