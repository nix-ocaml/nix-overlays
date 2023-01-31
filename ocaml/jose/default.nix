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
}:

buildDunePackage rec {
  pname = "jose";
  version = "0.8.2";
  src = builtins.fetchurl {
    url = "https://github.com/ulrikstrid/reason-jose/releases/download/v${version}/jose-v${version}.tbz";
    sha256 = "1yhh2qkd3z3kb6c8885aw11dnnwbjn15b8iipcvc1b65fwyzj8q1";
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
  ];
}
