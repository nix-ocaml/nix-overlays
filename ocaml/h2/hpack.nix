{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-h2";
    rev = "d447dd55e1ddd31ed6ae76651f336f378992618e";
    hash = "sha256-qt3SgBIhand5cqUMuN+qUEQM6+r97WRVFeMlCQ7lTxE=";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
