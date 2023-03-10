{ fetchFromGitHub, buildDunePackage, angstrom, faraday, gluten, httpaf, base64 }:

buildDunePackage {
  pname = "websocketaf";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "websocketaf";
    rev = "890a21453181a2a5230d598a87c2741defb2ade0";
    hash = "sha256-sNKEI4XnpBHL31OoKb+wZZGYeKEv0tM658igsxZeZww=";
  };

  propagatedBuildInputs = [ angstrom faraday gluten httpaf base64 ];
}
