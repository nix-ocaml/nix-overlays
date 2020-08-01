{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "jose";
  version = "0.5.1";
  src = builtins.fetchurl {
    url = "https://github.com/ulrikstrid/reason-jose/releases/download/v${version}/jose-v${version}.tbz";
    sha256 = "0kb0pn2zq8xc42rbg1f36cr63kr3csr7anijw01klr77w4x7bf2n";
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
