{ buildDunePackage, timedesc, yojson }:

buildDunePackage {
  pname = "timedesc-json";
  inherit (timedesc) src version;
  propagatedBuildInputs = [
    timedesc
    yojson
  ];
}
