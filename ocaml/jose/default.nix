{ buildDunePackage
, base64
, mirage-crypto
, mirage-crypto-pk
, mirage-crypto-ec
, x509
, cstruct
, astring
, yojson
, zarith
, result
}:

buildDunePackage rec {
  pname = "jose";
  version = "0.8.1";
  src = builtins.fetchurl {
    url = https://github.com/ulrikstrid/reason-jose/releases/download/v0.8.1/jose-v0.8.1.tbz;
    sha256 = "1pqd5pz1zj6h2hm3g4zbg3xqlx4vhc9s58w7vdq846a22z9g9vzw";
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
    result
  ];
}
