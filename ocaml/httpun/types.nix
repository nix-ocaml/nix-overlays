{ fetchFromGitHub, buildDunePackage, faraday }:

buildDunePackage {
  version = "0.1.0-dev";
  pname = "httpun-types";
  propagatedBuildInputs = [ faraday ];

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "httpun";
    rev = "c1c622617339d0ec69d5c3dd25dd72271ea4bed9";
    hash = "sha256-Czve6io/Mh87S9i1oKMrzqH9k1Ip3WuUzMCIIKshHMo=";
  };
}
