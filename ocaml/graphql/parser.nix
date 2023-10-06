{ fetchFromGitHub, buildDunePackage, alcotest, menhir, fmt, re }:

buildDunePackage {
  pname = "graphql_parser";
  version = "0.13.0-dev";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-graphql-server";
    rev = "01d5e5efedcd0245bc1a992ddf261fb39388c859";
    hash = "sha256-OS+pSgBZSoq8u+o6WO9ubnyTuWsIwSsRwpAO/8FZ768=";
  };

  nativeBuildInputs = [ menhir ];
  checkInputs = [ alcotest ];
  propagatedBuildInputs = [ menhir fmt re ];
}
