{ buildDunePackage
, fetchFromGitHub
, base64
, mirage-crypto
, mirage-crypto-pk
, mirage-crypto-ec
, x509
, cstruct
, astring
, yojson
, zarith
, ptime
}:

buildDunePackage {
  pname = "jose";
  version = "0.9.0";
  src = fetchFromGitHub {
    owner = "ulrikstrid";
    repo = "ocaml-jose";
    rev = "dc2778c611c693a89ee78b386cd4062bab7f7090";
    hash = "sha256-DCG+bsjE+hd4Bhjvhr4HhVrz/6G6RkPoBci7R1CXgOU=";
  };

  propagatedBuildInputs = [
    base64
    mirage-crypto
    mirage-crypto-pk
    mirage-crypto-ec
    x509
    cstruct
    astring
    yojson
    zarith
    ptime
  ];
}
