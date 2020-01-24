{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDune2Package {
  pname = "pg_query";
  version = "0.9.4-dev";

  src = fetchFromGitHub {
    owner = "roddyyaga";
    repo = "pg_query-ocaml";
    rev = "bae4c23d4a62f0b0559ed5a8552bf481574250de";
    sha256 = "1bx4zbnpyi0994r59xl91rw2iak1lmhqq8178i333wj4snkflk5w";
  };

  propagatedBuildInputs = with ocamlPackages; [
    ppx_inline_test
    ppx_deriving
    ctypes
  ];
}
