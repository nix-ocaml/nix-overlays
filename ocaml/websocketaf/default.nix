{ fetchFromGitHub, buildDunePackage, angstrom, faraday, gluten, httpaf, base64 }:

buildDunePackage {
  pname = "websocketaf";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "websocketaf";
    rev = "aa6a1472926ac496b3403a0dafb0360a1bb32623";
    hash = "sha256-Rzxr9AtDJAk/gZ19DI2ui2duB/9/F+m6lvJvnFm9bJc=";
  };

  propagatedBuildInputs = [ angstrom faraday gluten httpaf base64 ];

  postPatch = ''
    substituteInPlace lib/dune --replace "result" ""
  '';
}
