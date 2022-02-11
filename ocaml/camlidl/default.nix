{ lib, stdenv, fetchurl, ocaml, writeText }:

stdenv.mkDerivation rec {
  name = "camlidl-${version}";
  version = "1.09";

  src = fetchurl {
    url = https://github.com/xavierleroy/camlidl/archive/b508b03.tar.gz;
    sha256 = "0dg94w4cb2fja8c9zgkkp5vi8ak38ipx44s8xabwmvalah42hbk8";
  };

  buildInputs = [ ocaml ];

  preBuild = ''
    mv config/Makefile.unix config/Makefile
    substituteInPlace config/Makefile --replace BINDIR=/usr/local/bin BINDIR=$out
    substituteInPlace config/Makefile --replace 'OCAMLLIB=$(shell $(OCAMLC) -where)' OCAMLLIB=$out/lib/ocaml/${ocaml.version}/site-lib/camlidl
    substituteInPlace config/Makefile --replace CPP=/lib/cpp CPP=${stdenv.cc}/bin/cpp
    mkdir -p $out/lib/ocaml/${ocaml.version}/site-lib/camlidl/caml
    mkdir -p $out/lib/ocaml/${ocaml.version}/site-lib/camlidl/stublibs
  '';

  buildPhase = ''
    runHook preBuild
    make all
    runHook postBuild
  '';

  postInstall = ''
    cat >$out/lib/ocaml/${ocaml.version}/site-lib/camlidl/META <<EOF
    # Courtesy of GODI
    description = "Stub generator"
    version = "${version}"
    archive(byte) = "com.cma"
    archive(native) = "com.cmxa"
    EOF
    mkdir -p $out/bin
    ln -s $out/camlidl $out/bin
  '';

  setupHook = writeText "setupHook.sh" ''
    export CAML_LD_LIBRARY_PATH="''${CAML_LD_LIBRARY_PATH-}''${CAML_LD_LIBRARY_PATH:+:}''$1/lib/ocaml/${ocaml.version}/site-lib/${name}/"
    export NIX_CFLAGS_COMPILE+=" -isystem $1/lib/ocaml/${ocaml.version}/site-lib/camlidl"
    export NIX_LDFLAGS+=" -L $1/lib/ocaml/${ocaml.version}/site-lib/camlidl"
  '';
}
