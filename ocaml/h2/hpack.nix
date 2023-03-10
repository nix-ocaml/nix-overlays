{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-h2";
    rev = "d80e74b8ad78e782dd20eea433517b68f6d3af8d";
    hash = "sha256-gTNZOIMU+4gsa4shk1iKS65/OcMDRqzuPJl6vKfsC8U=";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
