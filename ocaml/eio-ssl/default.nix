{ fetchFromGitHub, buildDunePackage, ssl, eio }:

buildDunePackage {
  pname = "eio-ssl";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "eio-ssl";
    rev = "7973385ce6c4ee7f76df7753fcdfc69abb84da69";
    hash = "sha256-WJt+zYiYLlLb6xEv5XNU2ujhk6hn8epxCyCI+QbP1iE=";
  };
  propagatedBuildInputs = [ ssl eio ];
}
