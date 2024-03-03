{ fetchFromGitHub, buildDunePackage, alcotest, menhir, fmt, re }:

buildDunePackage {
  pname = "graphql_parser";
  version = "0.13.0-dev";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-graphql-server";
    rev = "0a5357d10364ecaf9aa17a3891c12481a713f7e2";
    hash = "sha256-VBkVB7EGjPECduWZlQdYO27VEFhT74MouOaz+dV5m+w=";
  };

  nativeBuildInputs = [ menhir ];
  checkInputs = [ alcotest ];
  propagatedBuildInputs = [ menhir fmt re ];
}
