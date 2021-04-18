{ lib, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "x509";
  version = "0.12.0";
  src = builtins.fetchurl {
    url = "https://github.com/mirleft/ocaml-x509/releases/download/v0.12.0/x509-v0.12.0.tbz";
    sha256 = "04g59j8sn8am0z0a94h8cyvr6cqzd5gkn2lj6g51nb5dkwajj19h";
  };

  buildInputs = [ alcotest cstruct-unix ];
  propagatedBuildInputs = [
    asn1-combinators
    domain-name
    fmt
    gmap
    mirage-crypto
    mirage-crypto-ec
    mirage-crypto-pk
    pbkdf
    rresult
    logs
    base64
  ];

  meta = {
    homepage = "https://github.com/mirleft/ocaml-x509";
    description = "X509 (RFC5280) handling in OCaml";
    license = lib.licenses.bsd2;
  };
}
