{ fetchFromGitHub, buildDunePackage, bigstringaf, faraday }:

buildDunePackage {
  pname = "gluten";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "gluten";
    rev = "c4e50854b1a535776d85d27fdedb632852ba6519";
    hash = "sha256-wl6fgMVz996su8+pRFzjvQa2BPDtsIo1eQ9X2REzJsc=";
  };
  propagatedBuildInputs = [ bigstringaf faraday ];
}
