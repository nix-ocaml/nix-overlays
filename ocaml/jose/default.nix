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
  version = "0.6.0";
  src = builtins.fetchurl {
    url = "https://github.com/ulrikstrid/reason-jose/releases/download/v${version}/jose-${version}.tbz";
    sha256 = "1k7pla4mwv51w32av4dhfcqp3hb206c2bknrna9aynk1rbhav3sh";
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
