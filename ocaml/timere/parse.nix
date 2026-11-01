{
  buildDunePackage,
  fetchzip,
  timere,
  oseq,
  re,
  containers,
  timedesc,
  mparser,
}:

buildDunePackage rec {
  pname = "timere-parse";
  version = "0.0.7";
  src = fetchzip {
    url = "https://github.com/daypack-dev/timere/releases/download/timere-parse-${version}/timere-parse-${version}.tar.gz";
    hash = "sha256-I/iiYnVP59AIxKwhYgPZEXMqG7XHNJNm85wwybKnDHA=";
    stripRoot = false;
  };

  propagatedBuildInputs = [
    oseq
    re
    containers
    timedesc
    timere
    mparser
  ];
}
