{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "graphql_ppx";
  version = "0.6.2-dev";

  src = fetchFromGitHub {
    owner = "reasonml-community";
    repo = "graphql_ppx";
    rev = "1ca111064da5aafa704ee53cc6acead49dcb52f4";
    sha256 = "01ivxbfak95sjdmfj4qzablkn40imp2mkpgkpain366cimz98zir";
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


