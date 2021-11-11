{ buildDunePackage, graphql, lwt, alcotest }:

buildDunePackage {
  pname = "graphql-lwt";
  inherit (graphql) src version;
  checkInputs = [ alcotest ];
  propagatedBuildInputs = [ graphql lwt ];
}
