{ fetchFromGitHub, buildDunePackage, angstrom, faraday, gluten, httpaf, base64 }:

buildDunePackage {
  pname = "websocketaf";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "websocketaf";
    rev = "259c553c7f930ff5c486b58dc87cd18cc30d8461";
    hash = "sha256-76RObHPa6EduMgAGVgZ4Yl/0exBMoVmUHwjAa3oXZ2M=";
  };

  propagatedBuildInputs = [ angstrom faraday gluten httpaf base64 ];

  postPatch = ''
    substituteInPlace lib/dune --replace "result" ""
  '';
}
