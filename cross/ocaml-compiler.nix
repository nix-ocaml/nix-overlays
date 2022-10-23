{ lib, buildPackages, natocamlPackages, writeScriptBin, osuper }:

let
  natocaml = natocamlPackages.ocaml;
  genWrapper = name: camlBin: writeScriptBin name ''
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
osuper.ocaml.overrideAttrs (o:
let isOCaml5 = lib.versionOlder "5.0" o.version;
in {
  depsBuildBuild = [ buildPackages.stdenv.cc ];
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
    else if lib.versionOlder "4.14" o.version
    then ./cross_4_14.patch
    else if lib.versionOlder "4.13" o.version
    then ./cross_4_13.patch
    else if lib.versionOlder "4.12" o.version
    then ./cross_4_12.patch
    else if lib.versionOlder "4.11" o.version
    then ./cross_4_11.patch
    else throw "OCaml ${o.version} not supported for cross-compilation")
  ];
})
