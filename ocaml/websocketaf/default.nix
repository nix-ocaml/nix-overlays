{ fetchFromGitHub, buildDunePackage, angstrom, faraday, gluten, httpaf, base64 }:

buildDunePackage {
  pname = "websocketaf";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "websocketaf";
    rev = "28abb768916f606287a2eb05a5d6a4aa11ec31b6";
    hash = "sha256-9VeOVw3ve+7tGsiLB9XdmgzpTAzc6DgR6CqLt/h3wB8=";
  };

  propagatedBuildInputs = [ angstrom faraday gluten httpaf base64 ];

  postPatch = ''
    substituteInPlace lib/dune --replace "result" ""
  '';
}
