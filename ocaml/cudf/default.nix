{ stdenv, ocamlPackages, perl }:

with ocamlPackages;

stdenv.mkDerivation rec {
  name = "cudf";
  buildInputs = [
    ocaml
    ocamlbuild
    # for pod2man
    perl
    findlib
  ];
  propagatedBuildInputs = [ ocaml_extlib ];
  src = builtins.fetchTarball {
    url = https://gforge.inria.fr/frs/download.php/36602/cudf-0.9.tar.gz;
    sha256 = "12p8aap34qsg1hcjkm79ak3n4b8fm79iwapi1jzjpw32jhwn6863";
  };
  buildPhase = ''
    make all opt
  '';
  patchPhase = "sed -i s@/usr/@$out/@ Makefile.config";
  createFindlibDestdir = true;
}
