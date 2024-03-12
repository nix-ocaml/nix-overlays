{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "bson";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-mongodb";
    rev = "6bc7cdfee3e5641077bfb77afdd9a6c66f8d1146";
    hash = "sha256-zedMSGo2HIaFM+nDDHkXbhTD30Q0iP0UI90BKZJKy9A=";
  };
  version = "0.0.1-dev";

  propagatedBuildInputs = [ angstrom faraday ];
}
