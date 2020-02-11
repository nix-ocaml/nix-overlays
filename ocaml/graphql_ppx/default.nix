{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "graphql_ppx";
  version = "0.6.2-dev";

  src = fetchFromGitHub {
    owner = "reasonml-community";
    repo = "graphql_ppx";
    rev = "6acea380923c5a698ae151aee93d7f87bea91915";
    sha256 = "0y6988jy5a8abz4x3qdclwppnfbhabbl4zs6k7xhg3skn6bzr607";
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


