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
, ptime
}:

buildDunePackage rec {
  pname = "jose";
  version = "0.9.0";
  src = builtins.fetchurl {
    url = "https://github.com/ulrikstrid/reason-jose/releases/download/v${version}/jose-v${version}.tbz";
    sha256 = "13f1vgr2ds46w9k4lyzic2sba6wpg3jha4zwkhafng84acyacjf4";
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
