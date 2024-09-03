{ fetchFromGitHub
, buildDunePackage
, angstrom
, faraday
, gluten
, httpun
, base64
}:

buildDunePackage {
  pname = "httpun-ws";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "httpun-ws";
    rev = "d8318adc66a83868e9022b4969082036c392ec0a";
    hash = "sha256-oaMgVLGQk7pkuryUedmZAgIlYWb8yxpMy+CbRog0I4g=";
  };

  propagatedBuildInputs = [ angstrom faraday gluten httpun base64 ];
}
