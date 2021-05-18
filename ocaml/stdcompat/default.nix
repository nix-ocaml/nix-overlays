{ lib, pkgs, autoconf, stdenv, opaline, ocamlPackages }:

with ocamlPackages;

let
  src = builtins.fetchurl {
    url = https://github.com/thierry-martinez/stdcompat/releases/download/v15/stdcompat-15.tar.gz;
    sha256 = "1xcwb529m4lg9cbnxa9m3x2nnl9nxzz1x5lxpvdfflg4zxl6yx2y";
  };
  name = "stdcompat";
in

stdenv.mkDerivation {
  pname = name;
  version = "15";
  inherit src;

  buildInputs = [
    ocaml
    findlib
  ];

  buildPhase = ''
    ./configure --prefix=$out
    make
  '';

  installPhase = ''
    make install
    cp $out/lib/${name}/* $OCAMLFIND_DESTDIR
  '';

  checkPhase = ''
    make all test
  '';

  meta = {
    description = "Compatibility module for OCaml standard library";
    license = lib.licenses.bsd2;
  };

  createFindlibDestdir = true;
}
