{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "tls";
  version = "0.11.0";
  src = builtins.fetchurl {
    url = "https://github.com/mirleft/ocaml-tls/releases/download/v${version}/tls-v${version}.tbz";
    sha256 = "1ia5li6sprapv3i5hmbqalljxh16jd4kq2pls6pi1ddvcjkcvqz0";
  };

  propagatedBuildInputs = [
    ppx_sexp_conv
    ppx_cstruct
    cstruct
    cstruct-sexp
    sexplib
    mirage-crypto
    mirage-crypto-pk
    mirage-crypto-rng
    x509
    domain-name
    fmt
    cstruct-unix
    lwt4
    ptime
  ];
}

