{ buildDunePackage, fetchFromGitHub }:

buildDunePackage {
  pname = "timedesc-tzlocal";
  version = "0.9.0";
  src = fetchFromGitHub {
    owner = "daypack-dev";
    repo = "timere";
    rev = "timedesc-1.2.0";
    hash = "sha256-KQkA+UhxPALKnrbFxiWKNb+Cc4LiaXkuxKPTZdVrftk=";
  };
}
