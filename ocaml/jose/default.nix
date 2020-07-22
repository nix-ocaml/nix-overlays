{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "jose";
  version = "0.4.0";
  src = builtins.fetchurl {
    url = https://github.com/ulrikstrid/reason-jose/archive/f4a9d1a484c1f4335210e4d9320b65d6a8594f45.tar.gz;
    sha256 = "0d251f75birpylmykrhpkznca0jqdz7qs6ckv4q253xcqk23lncr";
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
