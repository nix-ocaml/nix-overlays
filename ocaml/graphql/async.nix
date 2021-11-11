{ buildDunePackage, graphql, async, alcotest }:

buildDunePackage {
  pname = "graphql-async";
  inherit (graphql) src version;
  checkInputs = [ alcotest ];
  propagatedBuildInputs = [ graphql async ];
}
