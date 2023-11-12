{ fetchFromGitHub, buildDunePackage, ssl, eio }:

buildDunePackage {
  pname = "eio-ssl";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "eio-ssl";
    rev = "5e83c3ffb2200affde9d900de02f6994dd6421da";
    hash = "sha256-rkk4OA+kq2jFuKwVtR9MRDtMXt7WYc9fBB+CgY+n6Kc=";
  };
  propagatedBuildInputs = [ ssl eio ];
}
