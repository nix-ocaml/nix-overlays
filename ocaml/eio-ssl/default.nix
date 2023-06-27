{ fetchFromGitHub, buildDunePackage, ssl, eio }:

buildDunePackage {
  pname = "eio-ssl";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "eio-ssl";
    rev = "b6a2b00ddfd8e0ab93cc95705ef920c5159691d1";
    hash = "sha256-+oTa1mP73aolS1Vg+/R0mE3HXUpwS4fHMYM1sWG7RPo=";
  };
  propagatedBuildInputs = [ ssl eio ];
}
