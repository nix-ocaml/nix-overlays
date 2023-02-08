{ buildDunePackage, fetchFromGitHub }:

buildDunePackage {
  pname = "timedesc-tzlocal";
  version = "0.9.0";
  src = fetchFromGitHub {
    owner = "daypack-dev";
    repo = "timere";
    rev = "timedesc-0.9.0";
    sha256 = "sha256-q79D6t+eQwNPSJFbAtQ491+P54TJA32TBu427LGKzgQ=";
  };
}
