{ ocamlPackages, stdenv }:

with ocamlPackages;

stdenv.mkDerivation rec {
  pname = "flow_parser";
  version = "0.159.0";
  src = builtins.fetchurl {
    url = https://github.com/facebook/flow/archive/refs/tags/v0.159.0.tar.gz;
    sha256 = "17q0vxgri0ks8j13w94ysh19hlbmgy0ja7cs8087ngji0sjcd0hb";
  };

  buildPhase = ''
    make -C src/parser build-parser
  '';

  installPhase = ''
    make -C src/parser ocamlfind-install
  '';

  # patches = [ ./flow_parser_public_library.patch ];
  nativeBuildInputs = [ ocamlbuild ocaml findlib ];
  propagatedBuildInputs = [
    ppx_deriving
    ppx_gen_rec
    sedlex_3
    wtf8
  ];
}
