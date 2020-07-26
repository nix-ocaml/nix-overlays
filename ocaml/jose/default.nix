{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "jose";
  version = "0.5.0";
  src = builtins.fetchurl {
    url = https://github.com/ulrikstrid/reason-jose/releases/download/v0.5.0/jose-v0.5.0.tbz;
    sha256 = "03mr39rm6splhsyrlhp9rmzmh1b8nk3c8kf8n61ww389nc2866yf";
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
