{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "bson";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-mongodb";
    rev = "91f1c6d9d47be0585245851b1f97a74ea12b2bdd";
    hash = "sha256-g8j/LW3h/ItpFRBmMbd8DlJsSARNfNrJh0HuQIzyDMI=";
  };
  version = "0.0.1-dev";

  propagatedBuildInputs = [ angstrom faraday ];
}
