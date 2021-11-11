{ buildDunePackage, graphql_parser, yojson, rresult, seq, alcotest }:

buildDunePackage {
  pname = "graphql";
  inherit (graphql_parser) src version;
  checkInputs = [ alcotest ];
  propagatedBuildInputs = [ graphql_parser yojson rresult seq ];
}
