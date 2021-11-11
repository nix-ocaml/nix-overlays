{ buildDunePackage, mongo, mongo-lwt, gluten-lwt-unix }:

buildDunePackage {
  pname = "mongo-lwt-unix";
  inherit (mongo) src version;

  propagatedBuildInputs = [ mongo-lwt gluten-lwt-unix ];
}
