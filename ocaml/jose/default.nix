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
  version = "0.10.0";
  src = fetchFromGitHub {
    owner = "ulrikstrid";
    repo = "ocaml-jose";
    rev = "v0.10.0";
    hash = "sha256-bA2DAZ6N11sOOPz7bfePVtSAgIETXlgkwY3faKFqFIc=";
  };

  propagatedBuildInputs = [
    base64
    mirage-crypto
    mirage-crypto-pk
    mirage-crypto-ec
    x509
    astring
    yojson
    zarith
    ptime
  ];
}
