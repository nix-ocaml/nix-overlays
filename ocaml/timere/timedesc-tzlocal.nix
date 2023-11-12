{ buildDunePackage, fetchFromGitHub }:

buildDunePackage {
  pname = "timedesc-tzlocal";
  version = "2.0.0";
  src = fetchFromGitHub {
    owner = "daypack-dev";
    repo = "timere";
    rev = "timedesc-2.0.0";
    hash = "sha256-bHdRZMG9oGA0M7DSj6iC6kSwiTImBvNS/Pm1gSs/rY0=";
  };
}
