{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "httpaf";
    rev = "56411c8571154f520ab62be3ea0da03f991ae016";
    hash = "sha256-8i2IGluwa24AidugBS4BflVTYBs9PlnLPVjGifTX+3g=";
  };
}
