{ fetchFromGitHub, buildDunePackage, ssl, eio_main }:

buildDunePackage {
  pname = "eio-ssl";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "eio-ssl";
    rev = "5316c2a2";
    sha256 = "sha256-37Yj88Wx0rTXT5qFmszehw025FiZOlfbwHF64kdUZeo=";
  };
  propagatedBuildInputs = [ ssl eio_main ];
}
