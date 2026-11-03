{
  buildDunePackage,
  timedesc,
  yojson,
}:

buildDunePackage {
  pname = "timedesc-json";
  inherit (timedesc) src version sourceRoot;
  propagatedBuildInputs = [
    timedesc
    yojson
  ];
}
