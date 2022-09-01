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
    url = https://github.com/ulrikstrid/reason-jose/archive/59bc9002297020398a8c5d07508f97ec2a6c4a92.tar.gz;
    sha256 = "17s7h4r8ppsaj2n2pvrcrh0imss30m3zziyhic99bkizrr5bwfd5";
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
