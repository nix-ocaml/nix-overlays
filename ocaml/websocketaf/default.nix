{ fetchFromGitHub, buildDunePackage, angstrom, faraday, gluten, httpaf, base64 }:

buildDunePackage {
  pname = "websocketaf";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "websocketaf";
    rev = "c064e2641f3a878d621c1f705696aa8b6b246944";
    hash = "sha256-AEOUEwYfl3t6tproEusj+wbh4cIjb912YXl4aKeak9M=";
  };

  propagatedBuildInputs = [ angstrom faraday gluten httpaf base64 ];

  postPatch = ''
    substituteInPlace lib/dune --replace "result" ""
  '';
}
