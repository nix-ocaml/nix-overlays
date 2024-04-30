{ buildDunePackage, fetchFromGitHub }:

buildDunePackage {
  pname = "timedesc-tzlocal";
  version = "3.0.0";
  src = fetchFromGitHub {
    owner = "daypack-dev";
    repo = "timere";
    rev = "timedesc-3.1.0";
    hash = "sha256-b1tg2xtqbOkEEHsB7eRXWLSD3DTWGfJogeQZFF2/93E=";
  };
}
