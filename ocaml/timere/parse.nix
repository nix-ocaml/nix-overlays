{ buildDunePackage
, timere
, oseq
, re
, containers
, timedesc
, mparser
}:

buildDunePackage {
  pname = "timere-parse";
  inherit (timere) src version;
  propagatedBuildInputs = [
    oseq
    re
    containers
    timedesc
    timere
    mparser
  ];
}
