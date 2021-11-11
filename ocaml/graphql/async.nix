{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "graphql-async";
  inherit (graphql_parser) src version;
  checkInputs = [ alcotest ];
  propagatedBuildInputs = [ graphql async ];
}
