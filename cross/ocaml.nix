# Note to the future reader:
#
# As opposed to the other overlays, this one effectively virtualizes an opam
# switch. Dune is particular in how it finds its dependencies across build /
# host platforms, and emulating an opam switch layout makes it work seamlessly.
#
# The only obvious downside is that there can only be one of each, even at
# build time (e.g. OMP / ppxlib, etc that are possible to allow in the other
# overlays).

{ lib, buildPackages, writeText, writeScriptBin, makeWrapper, stdenv }:
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
        lib.stringAsChars
          (x: if x == "." then "_" else x)
          (builtins.substring 0
            (if lib.hasPrefix "5." osuper.ocaml.version then 3 else 4)
            osuper.ocaml.version);
    in
    buildPackages.ocaml-ng."ocamlPackages_${version}";
in
[
  # This currently needs to be split into 2 functions, to a) avoid infinite
  # recursion, and b) to avoid repeating the call to `fixOCamlPackage` in case
  # a derivation requires more than the `OCAMLFIND_CONF` env variable override.
  #
  # The 2 overlays have the following responsibilities:
  # 1. We set up the build toolchain with packages from `buildPackages`. These
  #    run on the build machine and should therefore be the same architecture.
  # 2. The 2nd overlay overrides package derivations (that are compiled for the
  #    host architecture)

  (oself: osuper:
    let
      crossName = lib.head (lib.splitString "-" stdenv.system);
      natocamlPackages = getNativeOCamlPackages osuper;
      natocaml = natocamlPackages.ocaml;
      natfindlib = natocamlPackages.findlib;
      natdune = natocamlPackages.dune;

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
            let
              inherit (oself) ocaml findlib;
            in
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

      fixOCamlPackage = b:
        b.overrideAttrs (o: {
          OCAMLFIND_CONF = makeFindlibConf b;
        });
    in

    (lib.mapAttrs
      (_: p: if p ? overrideAttrs then fixOCamlPackage p else p)
      osuper) // {
      ocaml = import ./ocaml-compiler.nix {
        inherit
          lib buildPackages writeScriptBin
          natocamlPackages osuper;
      };

      findlib = osuper.findlib.overrideAttrs (o: {
        postInstall = ''
          rm -rf $out/bin/ocamlfind
          cp ${natfindlib}/bin/ocamlfind $out/bin/ocamlfind
        '';
      });

      cppo = natocamlPackages.cppo;
      dune_2 = natocamlPackages.dune;
      dune_3 = natocamlPackages.dune;
      dune = natocamlPackages.dune;
      ocamlbuild = natocamlPackages.ocamlbuild;
      opaline = natocamlPackages.opaline;

      buildDunePackage = args: (osuper.buildDunePackage ({
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

  (oself: osuper:
    let
      crossName = lib.head (lib.splitString "-" stdenv.system);
      natocamlPackages = getNativeOCamlPackages osuper;

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

      ctypes = osuper.ctypes.overrideAttrs (o: {
        postInstall = ''
          echo -e '\nversion = "${o.version}"'>> $out/lib/ocaml/${osuper.ocaml.version}/aarch64-sysroot/lib/ctypes/META
        '';
      });

      cmdliner = osuper.cmdliner.overrideAttrs (o: {
        nativeBuildInputs = o.nativeBuildInputs ++ [ osuper.findlib ];

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
          ${oself.opaline}/bin/opaline -prefix $out -libdir $out/lib/ocaml/${osuper.ocaml.version}/site-lib/ ${o.pname}.install
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

      ocaml-migrate-parsetree = osuper.ocaml-migrate-parsetree-2;

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
        installPhase = osuper.topkg.installPhase;
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
    } // (lib.genAttrs [
      "astring"
      "jsonm"
      "fmt"
      "uutf"
      "uunf"
      "logs"
      "fpath"
      "bos"
      "ptime"
      "rresult"
      "mtime"
      "xmlm"
    ]
      (name: fixTopkgInstall osuper.${name} natocamlPackages.${name})))
]
