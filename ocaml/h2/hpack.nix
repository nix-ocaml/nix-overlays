{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-h2";
    rev = "5214b073d7c6a1fdada8414276a76f9368b73e4b";
    hash = "sha256-vo4kcwB9JWu0ul614ozthdGuXvfZ1BuvvixPhJjCius=";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
