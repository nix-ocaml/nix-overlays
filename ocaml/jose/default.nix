{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "jose";
  version = "0.4.0";
  src = builtins.fetchurl {
    url = "https://github.com/ulrikstrid/reason-jose/releases/download/v${version}/${pname}-v${version}.tbz";
    sha256 = "06npkd2hqlpnz84d4ba7bi8i2f81k0pnzhgd5a1c7nsjn20blzah";
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
