{ fetchFromGitHub, buildDunePackage, angstrom, faraday, gluten, httpaf, base64 }:

buildDunePackage {
  pname = "websocketaf";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "websocketaf";
    rev = "5986fbe8c959e4ff9b859faa8ea21b9ac813fd5e";
    sha256 = "sha256-xvKIRR5rSXRrRUhvNbjEWokCexFbYhHoL5aRsOaCfr0=";
  };

  propagatedBuildInputs = [ angstrom faraday gluten httpaf base64 ];
}
