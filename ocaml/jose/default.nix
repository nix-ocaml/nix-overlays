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
    url = https://github.com/ulrikstrid/reason-jose/archive/a8e43812.tar.gz;
    sha256 = "1f2w2k3x0nls52f6bdlx6ibhkadxy5v0wcbhshnil9nqjqldxafx";
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
