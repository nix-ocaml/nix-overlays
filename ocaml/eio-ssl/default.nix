{ fetchFromGitHub, buildDunePackage, ssl, eio }:

buildDunePackage {
  pname = "eio-ssl";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "eio-ssl";
    rev = "f8294caed5edf4801a8d1e5fe371d23dc9f6837d";
    hash = "sha256-oLOhkciZroy+PYVVrPUpm+48JCn2INHO3QP6SacXl+k=";
  };
  propagatedBuildInputs = [ ssl eio ];
}
