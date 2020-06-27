{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "multipart_form";

  version = "0.0.1-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "multipart_form";
    rev = "4fca5b07b929a9dc20faae3c2a1a175f249c5648";
    sha256 = "1y5rsbcjj0732qh4y1s6yn6bn0kwc7kiqnsxcljyhlmvd3241rq4";
  };

  propagatedBuildInputs = [
    astring
    base64
    pecu
    rosetta
    rresult
    uutf
    fmt
    angstrom
  ];
}
