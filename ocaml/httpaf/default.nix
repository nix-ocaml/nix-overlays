{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "httpaf";
    rev = "04a8b7bf77f726862a04519f6190eda6bd414329";
    hash = "sha256-XCiamLtCGZlaCWIXE8ExS6b4NtchSrdiWo8R2ak839k=";
  };
}
