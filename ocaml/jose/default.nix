{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "jose";
  version = "0.3.0";
  src = builtins.fetchurl {
    url = https://github.com/ulrikstrid/reason-jose/releases/download/v0.3.0/jose-v0.3.0.tbz;
    sha256 = "16jsxrc08agzvpaqr7nblhcj2j1h16p1miwvc7z6zhxsdnzic1dg";
  };

  propagatedBuildInputs = [
    base64
    mirage-crypto
    x509
    cstruct
    astring
    yojson
    zarith
    result
  ];
}
