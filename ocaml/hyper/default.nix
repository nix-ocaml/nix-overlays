{ fetchFromGitHub
, buildDunePackage
, dream-httpaf
, dream-pure
, mirage-crypto-rng-lwt
, uri
}:

buildDunePackage rec {
  pname = "hyper";
  version = "1.0.0-alpha1";

  src = fetchFromGitHub {
    owner = "aantron";
    repo = "hyper";
    rev = "ca0a287b9e4e9c7e960daa8d1ecf2d82f073e3bb";
    hash = "sha256-MwJdT1JzJQuM2yeRSZ6LaYqspZ4Is5K9kNoHHdOdaiw=";
  };

  propagatedBuildInputs = [
    dream-httpaf
    dream-pure
    uri
    mirage-crypto-rng-lwt
  ];
}
