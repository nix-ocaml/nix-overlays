{ buildDunePackage, bson }:

buildDunePackage {
  pname = "mongo";
  inherit (bson) src version;

  propagatedBuildInputs = [ bson ];
}
