{ fetchFromGithub, ocamlPackages }:

stdenv.mkDerivation {
  name = "dose";
  src = builtins.fetchurl {
    url = "http://gforge.inria.fr/frs/download.php/file/36063/dose3-5.0.1.tar.gz";
    sha256 = "00yvyfm4j423zqndvgc1ycnmiffaa2l9ab40cyg23pf51qmzk2jm";
  };
  buildInputs = with esyOcamlPkgs; [
    ocaml
    findlib
    ocamlbuild
    cppo
    perl
  ];
  propagatedBuildInputs = with esyOcamlPkgs; [
    cudf
    ocaml_extlib
    ocamlgraph
    re
  ];
  createFindlibDestdir = true;
  patches = [
    ./patches/0001-Install-mli-cmx-etc.patch
    ./patches/0002-dont-make-printconf.patch
    ./patches/0003-Fix-for-ocaml-4.06.patch
    ./patches/0004-Add-unix-as-dependency-to-dose3.common-in-META.in.patch
    ./patches/dose.diff
  ];
}
