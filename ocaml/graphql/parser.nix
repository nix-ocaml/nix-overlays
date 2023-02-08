{ fetchFromGitHub, buildDunePackage, alcotest, menhir, fmt, re }:

buildDunePackage {
  pname = "graphql_parser";
  version = "0.13.0-dev";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-graphql-server";
    rev = "8266322ca1c5297bd875acf6ed42f8d14168c7d8";
    sha256 = "sha256-6Vn5ajlQ5c0Rtljjjqp+C3PnflExMltWLDIqGSvAfFg=";
  };

  nativeBuildInputs = [ menhir ];
  checkInputs = [ alcotest ];
  propagatedBuildInputs = [ menhir fmt re ];
}
