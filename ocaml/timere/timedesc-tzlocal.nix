{ buildDunePackage, fetchFromGitHub }:

buildDunePackage {
  pname = "timedesc-tzlocal";
  version = "3.0.0";
  src = fetchFromGitHub {
    owner = "daypack-dev";
    repo = "timere";
    rev = "timedesc-3.0.0";
    hash = "sha256-TW4gQ2PLShSJsXGpgfUerXX7DeyF5rOIptfE/0dwyLg=";
  };
}
