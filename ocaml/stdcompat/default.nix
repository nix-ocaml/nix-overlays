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

  propagatedBuildInputs = [
    ocaml
    findlib
    uchar
  ];

  buildPhase = ''
    echo "out: $out"
    ./configure --prefix=$out
    make all test
  '';

  installPhase = ''
    make install
    cp -r $out/lib/${name} $OCAMLFIND_DESTDIR/
  '';

  doCheck = true;

  checkPhase = ''
    make all test
  '';

  meta = {
    description = "Compatibility module for OCaml standard library";
    license = lib.licenses.bsd2;
  };

  createFindlibDestdir = true;
}
