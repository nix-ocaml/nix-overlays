{ fetchFromGitHub
, buildDunePackage
, ppx_inline_test
, ppx_deriving
, ctypes
, ctypes-foreign
}:

buildDunePackage {
  pname = "pg_query";
  version = "0.9.7";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "pg_query-ocaml";
    rev = "f9f7a63363a56bf885bd84c68385696abe494e2f";
    hash = "sha256-60OYony6I5+6tLLlGWQ4pbFO8N3ZWJrjKztiKMyKHsQ=";
  };

  postPatch = ''
    rm -rf bin/
  '';

  propagatedBuildInputs = [
    ppx_inline_test
    ppx_deriving
    ctypes
    ctypes-foreign
  ];
}
