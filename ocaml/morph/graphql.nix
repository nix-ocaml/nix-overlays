{ lib
, buildDunePackage
, reason
, logs
, lwt
, morph
, graphql
, graphql-lwt
}:

buildDunePackage {
  pname = "morph_graphql_server";
  inherit (morph) src version;

  propagatedBuildInputs = [
    reason
    logs
    lwt
    morph
    graphql
    graphql-lwt
  ];

  meta = {
    description = "Helpers for working with graphql and morph";
    license = lib.licenses.mit;
  };
}
