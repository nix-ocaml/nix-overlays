{ ocamlPackages, lib }:

with ocamlPackages;

buildDunePackage {
  pname = "mongo-lwt-unix";
  inherit (bson) src version;

  propagatedBuildInputs = [ mongo-lwt gluten-lwt-unix ];
}
