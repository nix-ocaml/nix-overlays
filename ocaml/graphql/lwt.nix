{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "graphql-lwt";
  inherit (graphql_parser) src version;
  checkInputs = [ alcotest ];
  propagatedBuildInputs = [ graphql lwt ];
}
