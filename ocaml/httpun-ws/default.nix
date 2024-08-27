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
    rev = "9aacc120032c3f5b03b8775c82000d1cfe2b51ac";
    hash = "sha256-UrGyoNeQo9tDMtCZDSbLNCFhi/7krqnIMf5nUAEdAWI=";
  };

  propagatedBuildInputs = [ angstrom faraday gluten httpun base64 ];
}
