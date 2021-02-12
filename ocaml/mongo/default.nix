{ ocamlPackages, lib }:

with ocamlPackages;

buildDunePackage {
  pname = "mongo";
  inherit (bson) src version;

  propagatedBuildInputs = [ bson ];
}
