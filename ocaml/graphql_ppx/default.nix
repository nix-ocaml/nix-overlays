{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "graphql_ppx";
  version = "0.6.2-dev";

  src = fetchFromGitHub {
    owner = "reasonml-community";
    repo = "graphql_ppx";
    rev = "e240bf3e58b4d14d663cf83d5bb51b40022ba49d";
    sha256 = "0xga0ai992pm81n4j6mm10s58d1axmgi6angvrv2jqd49rl4yxcj";
  };

  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs = [
    yojson
    ocaml-migrate-parsetree
    ppx_tools_versioned
    reason
    menhir
  ];
}


