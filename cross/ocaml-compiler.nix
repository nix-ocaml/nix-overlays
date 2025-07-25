{ stdenv, lib, buildPackages, natocamlPackages, writeScriptBin, osuper, windows }:

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
  depsBuildBuild = [ buildPackages.stdenv.cc natocaml ] ;

  buildInputs = lib.optional stdenv.hostPlatform.isMinGW [
    windows.mingw_w64_pthreads
  ];

  preConfigure = ''
    configureFlagsArray+=("PARTIALLD=$LD -r" "ASPP=$CC -c")
    installFlagsArray+=("OCAMLRUN=${natocaml}/bin/ocamlrun")
  '';
  # host is wrong
  configurePlatforms = ["target"];
  configureFlags = o.configureFlags ++ [ "--disable-ocamldoc" ];
  postConfigure = ''
    cp Makefile.config Makefile.config.bak
    echo 'SAK_CC=${buildPackages.stdenv.cc}/bin/gcc' >> Makefile.config
    echo 'SAK_CFLAGS=$(OC_CFLAGS) $(OC_CPPFLAGS)' >> Makefile.config
    echo 'SAK_LINK=$(SAK_CC) $(SAK_CFLAGS) $(OUTPUTEXE)$(1) $(2)' >> Makefile.config
    substituteInPlace Makefile.config --replace-fail \
      -exe \
      "-exe -L ${windows.mingw_w64_pthreads}/lib"
    substituteInPlace Makefile.config --replace-fail \
      -lgcc_eh \
      ""
  '';

  buildPhase = "make crossopt";
  installTargets = [ "installcross" ] ;
  postInstall = ''
    ln -s $out/bin/ocaml.exe $out/bin/ocaml
    ln -s $out/bin/ocamlc.exe $out/bin/ocamlc
    ln -s $out/bin/ocamlopt.exe $out/bin/ocamlopt
  '';
  patches =
    ( if lib.versionOlder "5.4" o.version
    then []
    else if lib.versionOlder "5.3" o.version
    then [./cross_5_3.patch]
    else if lib.versionOlder "5.2" o.version
    then [./cross_5_2.patch]
    else if lib.versionOlder "5.1" o.version
    then [./cross_5_1.patch]
    else if isOCaml5
    then [./cross_5_00.patch]
    else if lib.versionOlder "4.14" o.version
    then [./cross_4_14.patch]
    else if lib.versionOlder "4.13" o.version
    then [./cross_4_13.patch]
    else if lib.versionOlder "4.12" o.version
    then [./cross_4_12.patch]
    else if lib.versionOlder "4.11" o.version
    then [./cross_4_11.patch]
    else throw "OCaml ${o.version} not supported for cross-compilation")
  ;
  postPatch = [
    ''
    substituteInPlace \
    runtime/dynlink.c \
      --replace-fail \
      OCAML_STDLIB_DIR \
      "(char_os *) OCAML_STDLIB_DIR "
    ''
  ];
})
