{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "httpaf";
    rev = "7189cd28e21203117f0c8e2347ae9a2fe0e0c157";
    sha256 = "sha256-uj1wyZWYpQt0TiBFWb2ugV1xEG6OlLLXnO4UcZEkscU=";
  };
}
