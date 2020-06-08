{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "reason";
  version = "3.6.0";

  src = fetchFromGitHub {
    owner = "facebook";
    repo = "reason";
    rev = "773dbcd0982ff7b775a567f3c7b754ad15c165b1";
    sha256 = "0ackkavqjzs1b390mq122c1ks18rarmwhprb83byvxfg5xrbjnsp";
  };

  propagatedBuildInputs = [ menhir fix merlin-extend ocaml-migrate-parsetree ];

  buildInputs = [ cppo menhir ];

  patches = [
    ./patches/0001-rename-labels.patch
  ];
}
