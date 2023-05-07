{ fetchFromGitHub, buildDunePackage, ppx_inline_test, ppx_deriving, ctypes, ctypes-foreign }:

buildDunePackage {
  pname = "pg_query";
  version = "0.9.7";

  src = fetchFromGitHub {
    owner = "roddyyaga";
    repo = "pg_query-ocaml";
    rev = "9b37b2b2937fe9e1e52f778cd897acef458e8327";
    hash = "sha256-Fa/EjlI3lUOwv/6lhokrYkn6qI5EkhOGY6iPnno492c=";
  };
  postPatch = ''
    rm -rf bin/
    substituteInPlace lib/dune --replace "ctypes.foreign" "ctypes-foreign"
    substituteInPlace lib/libpg_query/Makefile --replace \
      "AR = ar rs" "AR ?= ar
    AR := \$(AR) rs"
  '';

  propagatedBuildInputs = [ ppx_inline_test ppx_deriving ctypes ctypes-foreign ];
}
