{ ocamlPackages, stdenv, lib, pkgs }:

let
  src = builtins.fetchurl {
    url = https://github.com/thierry-martinez/pyml/archive/20210226.tar.gz;
    sha256 = "0nafp4gk10f74qx1xs0rc6fin332zqqryyy0xlmh3wf4p3680pcq";
  };
  name = "pyml";
in

stdenv.mkDerivation {
  pname = name;
  version = "20210226";
  inherit src;

  buildInputs = with ocamlPackages; [
    ocaml
    findlib
    utop
  ];
  

  propagatedBuildInputs = [
    pkgs.python3
    ocamlPackages.stdcompat
  ];

  buildPhase = ''
    echo $OCAMLPATH
    echo ${ocamlPackages.stdcompat}
    make all pymltop pymlutop
  '';

  installPhase = ''
    echo "out $out"
    mkdir -p $out/bin
    mkdir -p $OCAMLFIND_DESTDIR
    echo "install"
    make install PREFIX=$out
    # cp $out/lib/${name} $OCAMLFIND_DESTDIR/
  '';

  doCheck = true;

  meta = {
    description = "OCaml bindings for Python";
    license = lib.licenses.bsd2;
  };
}
