{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "graphql";
  inherit (graphql_parser) src version;
  checkInputs = [ alcotest ];
  propagatedBuildInputs = [ graphql_parser yojson rresult seq ];
}
