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
      findNativePackage = p:
        if p ? pname then
          let
            pname = p.pname or (throw "`p.pname' not found: ${p.name}");
          in
            natocamlPackages."${pname}" or
              # Some legacy packages are called `ocaml_X`, e.g. extlib and
              # sqlite3
              natocamlPackages."ocaml_${pname}" or
                (
                  let
                    prefix1 = "ocaml${osuper.ocaml.version}-";
                    prefix2 = "ocaml-";
                  in
                  if lib.hasPrefix prefix1 p.pname
                  then natocamlPackages."${(lib.removePrefix prefix1 pname)}"
                  else if lib.hasPrefix prefix2 p.pname
                  then natocamlPackages."${(lib.removePrefix prefix2 pname)}"
                  else throw "Unsupported cross-pkg parsing for `${p.pname}'"
                )
        else { };

      makeFindlibConf = nativePackage: package:
        let
          inputs = mergeInputs [
            "propagatedBuildInputs"
            "buildInputs"
            "checkInputs"
          ]
            package;
          natInputs = mergeInputs [
            "propagatedBuildInputs"
            "buildInputs"
            "nativeBuildInputs"
          ]
            nativePackage;

          path =
            builtins.concatStringsSep ":"
              (builtins.map (x: "${x.outPath}/lib/ocaml/${natocaml.version}/${crossName}-sysroot/lib")
                inputs);
          natPath =
            builtins.concatStringsSep ":"
              (builtins.map (x: "${x.outPath}/lib/ocaml/${natocaml.version}/site-lib")
                natInputs);

          native_findlib_conf =
            writeText "${package.name or package.pname}-findlib.conf" ''
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
            writeText "${package.name or package.pname}-${crossName}.conf" ''
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
            name = "${package.name or package.pname}-findlib-conf";
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
          OCAMLFIND_CONF = makeFindlibConf (findNativePackage b) b;
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

        passthru = { inherit makeFindlibConf; };

        setupHook = writeText "setupHook.sh" ''
          addOCamlPath () {
              if test -d "''$1/lib/ocaml/${oself.ocaml.version}/site-lib"; then
                  export OCAMLPATH="''${OCAMLPATH-}''${OCAMLPATH:+:}''$1/lib/ocaml/${oself.ocaml.version}/site-lib/"
              fi
              if test -d "''$1/lib/ocaml/${oself.ocaml.version}/site-lib/stublibs"; then
                  export CAML_LD_LIBRARY_PATH="''${CAML_LD_LIBRARY_PATH-}''${CAML_LD_LIBRARY_PATH:+:}''$1/lib/ocaml/${oself.ocaml.version}/site-lib/stublibs"
              fi
          }
          exportOcamlDestDir () {
              export OCAMLFIND_DESTDIR="''$out/lib/ocaml/${oself.ocaml.version}/${crossName}-sysroot/lib/"
          }
          createOcamlDestDir () {
              if test -n "''${createFindlibDestdir-}"; then
                mkdir -p $OCAMLFIND_DESTDIR
              fi
          }
          detectOcamlConflicts () {
            local conflict
            conflict="$(ocamlfind list |& grep "has multiple definitions" | grep -vE "bigarray|unix|str|stdlib|compiler-libs|threads|bytes|dynlink|findlib" || true)"
            if [[ -n "$conflict" ]]; then
              echo "Conflicting ocaml packages detected";
              echo "$conflict"
              exit 1
            fi
          }
          # run for every buildInput
          addEnvHooks "$targetOffset" addOCamlPath
          # run before installPhase, even without buildInputs, and not in nix-shell
          preInstallHooks+=(createOcamlDestDir)
          # run even in nix-shell, and even without buildInputs
          addEnvHooks "$hostOffset" exportOcamlDestDir
          # runs after all calls to addOCamlPath
          if [[ -z "''${dontDetectOcamlConflicts-}" ]]; then
            postHooks+=("detectOcamlConflicts")
          fi
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
          ''
            runHook preInstall
            dune install ${args.pname} -x ${crossName} \
              --prefix $out --libdir $(dirname $OCAMLFIND_DESTDIR) \
              --docdir $out/share/doc --man $out/share/man
            runHook postInstall
          '';
      } // args
      )).overrideAttrs (o: {
        nativeBuildInputs =
          (o.nativeBuildInputs or [ ]) ++ [ buildPackages.stdenv.cc ];
      });

      topkg = natocamlPackages.topkg.overrideAttrs (o:
        let
          run = "${natocaml}/bin/ocaml -I ${natfindlib}/lib/ocaml/${osuper.ocaml.version}/site-lib pkg/pkg.ml";
        in
        {
          selfBuild = true;

          passthru = {
            inherit run;
          };

          buildPhase = "${run} build";

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
    in
    {
      camlzip = osuper.camlzip.overrideAttrs (_: {
        OCAMLFIND_TOOLCHAIN = "${crossName}";
        postInstall = ''
          ln -sfn $OCAMLFIND_DESTDIR/{,caml}zip
        '';
      });

      ctypes = osuper.ctypes.overrideAttrs (o: {
        postInstall = ''
          echo -e '\nversion = "${o.version}"'>> $out/lib/ocaml/${osuper.ocaml.version}/${crossName}-sysroot/lib/ctypes/META
        '';
      });

      cmdliner = osuper.cmdliner.overrideAttrs (o: {
        nativeBuildInputs = o.nativeBuildInputs ++ [ oself.findlib ];

        installFlags = [
          "LIBDIR=$(OCAMLFIND_DESTDIR)/${o.pname}"
          "DOCDIR=$(out)/share/doc/${o.pname}"
        ];
        postInstall = ''
          mv $OCAMLFIND_DESTDIR/${o.pname}/{opam,${o.pname}.opam}
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
          ${oself.opaline}/bin/opaline -prefix $out -libdir $OCAMLFIND_DESTDIR ${o.pname}.install
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
      });

      ocaml-migrate-parsetree = osuper.ocaml-migrate-parsetree-2;

      seq = osuper.seq.overrideAttrs (o: {
        nativeBuildInputs = [ oself.findlib ];
        installPhase = ''
          install_dest="$OCAMLFIND_DESTDIR/seq/"
          mkdir -p $install_dest
          mv META $install_dest
        '';
      });

      uchar = osuper.uchar.overrideAttrs (_: {
        installPhase = oself.topkg.installPhase;
      });

      zarith = osuper.zarith.overrideAttrs (o: {
        configurePlatforms = [ ];
        OCAMLFIND_TOOLCHAIN = "${crossName}";
        configureFlags = [
        ];
        configurePhase = ''
          ./configure -prefixnonocaml ${stdenv.cc.targetPrefix} -installdir $OCAMLFIND_DESTDIR
        '';
        preBuild = ''
          buildFlagsArray+=("host=${stdenv.hostPlatform.config}")
        '';
        preInstall = "mkdir -p $OCAMLFIND_DESTDIR";
      });
    })
]
