{
  stdenv,
  lib,
  buildPackages,
  natocamlPackages,
  writeScriptBin,
  osuper,
  windows ? null,
}:

let
  natocaml = natocamlPackages.ocaml;
  genWrapper =
    name: camlBin:
    writeScriptBin name ''
      #!${buildPackages.stdenv.shell}
      NEW_ARGS=""

      for ARG in "$@"; do NEW_ARGS="$NEW_ARGS \"$ARG\""; done
      eval "${camlBin} $NEW_ARGS"
    '';
  ocamlcHostWrapper = genWrapper "ocamlcHost.wrapper" "${natocaml}/bin/ocamlc.opt -I ${natocaml}/lib/ocaml -I ${natocaml}/lib/ocaml/stublibs -I +unix -nostdlib ";
  ocamloptHostWrapper = genWrapper "ocamloptHost.wrapper" "${natocaml}/bin/ocamlopt.opt -I ${natocaml}/lib/ocaml -I +unix -nostdlib ";

  ocamlcTargetWrapper = genWrapper "ocamlcTarget.wrapper" "$BUILD_ROOT/ocamlc.opt -I $BUILD_ROOT/stdlib -I $BUILD_ROOT/otherlibs/unix -I ${natocaml}/lib/ocaml/stublibs -nostdlib ";
  ocamloptTargetWrapper = genWrapper "ocamloptTarget.wrapper" "$BUILD_ROOT/ocamlopt.opt -I $BUILD_ROOT/stdlib -I $BUILD_ROOT/otherlibs/unix -nostdlib ";

in

if lib.versionOlder "5.4" osuper.ocaml.version then
  osuper.ocaml.overrideAttrs (o: {
    depsBuildBuild = [
      buildPackages.stdenv.cc
      natocaml
    ];

    # mingw needs pthreads for threading support
    buildInputs = lib.optionals stdenv.hostPlatform.isMinGW [
      windows.pthreads
    ];

    configurePlatforms = [ ];
    preConfigure = ''
      configureFlagsArray+=("--host=${stdenv.buildPlatform.config}" "--target=${stdenv.targetPlatform.config}" "PARTIALLD=$LD -r" "ASPP=$CC -c")
    '';

    # mingw: add pthreads path to flexlink, remove -lgcc_eh, add -nocygpath
    postConfigure = lib.optionalString stdenv.hostPlatform.isMinGW ''
      # Add -nocygpath to prevent flexlink from trying to use cygpath
      # Add -L path for pthreads to all flexlink invocations
      substituteInPlace Makefile.config --replace-fail \
        'MKEXE=flexlink' \
        'MKEXE=flexlink -nocygpath -L${windows.pthreads}/lib'
      substituteInPlace Makefile.config --replace-fail \
        'MKDLL=flexlink' \
        'MKDLL=flexlink -nocygpath -L${windows.pthreads}/lib'
      substituteInPlace Makefile.config --replace-fail \
        'MKMAINDLL=flexlink' \
        'MKMAINDLL=flexlink -nocygpath -L${windows.pthreads}/lib'
      substituteInPlace Makefile.config --replace-fail \
        '-lgcc_eh' \
        ""
    '';

    buildPhase = ''
      runHook preBuild
      make crossopt ''${enableParallelBuilding:+-j $NIX_BUILD_CORES}
      runHook postBuild
    '';
    installTargets = [ "installcross" ];
    postInstall = ''
      cp ${natocaml}/bin/ocamllex $out/bin/ocamllex
      cp ${natocaml}/bin/ocamlyacc $out/bin/ocamlyacc
      cp ${natocaml}/bin/ocamlrun $out/bin/ocamlrun
    ''
    + lib.optionalString stdenv.hostPlatform.isMinGW ''
            # Remove Windows PE versions of tools that need to run on build machine
            # The cross-compiler .exe files are actually ELF binaries (run on Linux)
            # but ocamlyacc.exe and ocamlrun.exe are Windows PE (compiled with mingw gcc)
            rm -f $out/bin/ocamlyacc.exe $out/bin/ocamlrun.exe $out/bin/ocamlrund.exe

            # Create symlinks for .exe files (mingw adds .exe extension)
            for f in $out/bin/*.exe; do
              ln -sf "$(basename "$f")" "''${f%.exe}"
            done

            # Wrap flexlink to always add -nocygpath and library paths
            # The compiler has flexlink settings compiled-in that don't include these
            # Link mcfgthread which is needed by libgcc_eh
            mv $out/bin/flexlink.opt.exe $out/bin/.flexlink.opt.exe.real
            cat > $out/bin/flexlink.opt.exe << 'EOF'
      #!/bin/sh
      exec "$(dirname "$0")/.flexlink.opt.exe.real" -nocygpath -L${windows.pthreads}/lib -L${windows.mcfgthreads}/lib "$@" -lmcfgthread
      EOF
            chmod +x $out/bin/flexlink.opt.exe

            # Update symlinks to point to the wrapper
            ln -sf flexlink.opt.exe $out/bin/flexlink.exe
            ln -sf flexlink.opt.exe $out/bin/flexlink.opt
            ln -sf flexlink.opt.exe $out/bin/flexlink
    '';
  })
else
  osuper.ocaml.overrideAttrs (
    o:
    let
      isOCaml5 = lib.versionOlder "5.0" o.version;
    in
    {
      depsBuildBuild = [ buildPackages.stdenv.cc ];
      preConfigure = ''
        configureFlagsArray+=("PARTIALLD=$LD -r" "ASPP=$CC -c")
        installFlagsArray+=("OCAMLRUN=${natocaml}/bin/ocamlrun")
      '';
      configureFlags = o.configureFlags ++ [ "--disable-ocamldoc" ];
      postConfigure = ''
        cp Makefile.config Makefile.config.bak
        echo 'SAK_CC=${buildPackages.stdenv.cc}/bin/gcc' >> Makefile.config
        echo 'SAK_CFLAGS=$(OC_CFLAGS) $(OC_CPPFLAGS)' >> Makefile.config
        echo 'SAK_LINK=$(SAK_CC) $(SAK_CFLAGS) $(OUTPUTEXE)$(1) $(2)' >> Makefile.config
      '';

      buildPhase = ''
        runHook preBuild

        OCAML_HOST=${natocaml}
        OCAMLRUN="$OCAML_HOST/bin/ocamlrun"
        OCAMLLEX="$OCAML_HOST/bin/ocamllex"
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
               OCAMLLEX="$OCAMLLEX" \
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
        make_target ocamlopt
        make_target otherlibraries otherlibrariesopt ocamltoolsopt \
                    driver/main.cmx driver/optmain.cmx

        # build the compiler shared libraries with the target `zstd.npic.o`
        cp Makefile.config.bak Makefile.config
        echo 'SAK_CC=${stdenv.cc.targetPrefix}gcc' >> Makefile.config
        make_target compilerlibs/ocamlcommon.cmxa \
                    compilerlibs/ocamlbytecomp.cmxa \
                    compilerlibs/ocamloptcomp.cmxa
        ${if isOCaml5 then "make_target othertools" else ""}

        runHook postBuild
      '';
      installTargets = o.installTargets ++ [ "installoptopt" ];
      postInstall = "cp ${natocaml}/bin/ocamlyacc $out/bin/ocamlyacc";
      patches = [
        (
          if lib.versionOlder "5.3" o.version then
            ./cross_5_3.patch
          else if lib.versionOlder "5.2" o.version then
            ./cross_5_2.patch
          else if lib.versionOlder "5.1" o.version then
            ./cross_5_1.patch
          else if isOCaml5 then
            ./cross_5_00.patch
          else if lib.versionOlder "4.14" o.version then
            ./cross_4_14.patch
          else if lib.versionOlder "4.13" o.version then
            ./cross_4_13.patch
          else if lib.versionOlder "4.12" o.version then
            ./cross_4_12.patch
          else if lib.versionOlder "4.11" o.version then
            ./cross_4_11.patch
          else
            throw "OCaml ${o.version} not supported for cross-compilation"
        )
      ];
    }
  )
