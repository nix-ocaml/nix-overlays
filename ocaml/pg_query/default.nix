{ fetchFromGitHub, buildDunePackage, ppx_inline_test, ppx_deriving, ctypes, ctypes-foreign }:

buildDunePackage {
  pname = "pg_query";
  version = "0.9.7";

  src = fetchFromGitHub {
    owner = "roddyyaga";
    repo = "pg_query-ocaml";
    rev = "0.9.7";
    sha256 = "sha256-Dj25h3UTfm7UPynIIh3IjMDkeFUrYvW5nv7BmpbqkRM=";
  };
  postPatch = ''
    rm -rf bin/
    substituteInPlace lib/dune --replace "ctypes.foreign" "ctypes-foreign"
  '';

  useDune2 = true;

  propagatedBuildInputs = [ ppx_inline_test ppx_deriving ctypes ctypes-foreign ];
}
