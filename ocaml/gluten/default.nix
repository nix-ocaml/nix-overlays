{ fetchFromGitHub, buildDunePackage, bigstringaf, faraday }:

buildDunePackage {
  pname = "gluten";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "gluten";
    rev = "166e1e917710e1e43b04d33a368b6701a9f8b1f5";
    hash = "sha256-wl6fgMVz996su8+pRFzjvQa2BPDtsIo1eQ9X2REzJsc=";
  };
  propagatedBuildInputs = [ bigstringaf faraday ];
}
