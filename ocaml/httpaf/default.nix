{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "httpaf";
    rev = "4167b5d";
    sha256 = "sha256-uj1wyZWYpQt0TiBFWb2ugV1xEG6OlLLXnO4UcZEkscU=";
  };
}
