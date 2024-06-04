{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpun";
  propagatedBuildInputs = [ angstrom faraday ];

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "httpun";
    rev = "d6f8d6ca29a9f7a5d1d2c116a4fd6fc1a048d2dc";
    hash = "sha256-oMO/6dfKggSyQCwX7pYglOc1lFgKv8TwTbN4OWWNMjI=";
  };
}
