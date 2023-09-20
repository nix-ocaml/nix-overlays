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

buildDunePackage rec {
  pname = "jose";
  version = "0.9.0";
  src = fetchFromGitHub {
    owner = "ulrikstrid";
    repo = "ocaml-jose";
    rev = "945032261126baa4d8d23eeee300c42f0c5feaad";
    hash = "sha256-P7lbK68GMTeZ5sH3d7jbdtjbo6yDKQJNdbM7SXsRMHI=";
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
