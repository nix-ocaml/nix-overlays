{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "jose";
  version = "0.5.5-dev";
  src = fetchFromGitHub {
    owner = "ulrikstrid";
    repo = "reason-jose";
    rev = "2458d620c9c6f506bdde9ead7ae485b910fbdf0d";
    sha256 = "1n1z5rfjqankh3ycflhr4v897hx4rby760z1n9dp6kvck065j1ll";
  };

  propagatedBuildInputs = [
    base64
    nocrypto
    x509
    cstruct
    astring
    yojson
    zarith
  ];
}
