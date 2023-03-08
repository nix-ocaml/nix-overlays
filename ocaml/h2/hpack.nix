{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-h2";
    rev = "ce23570";
    hash = "sha256-GHD0Dyb47fkgTOJ6TPlhqdHxtPT444MOyjoLUxdHy7A=";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
