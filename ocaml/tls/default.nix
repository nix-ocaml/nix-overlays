{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "tls";
  version = "0.11.1";
  src = builtins.fetchurl {
    url = "https://github.com/mirleft/ocaml-tls/releases/download/v${version}/tls-v${version}.tbz";
    sha256 = "0ms13fbaxgmpbviazlfa4hb7nmi7s22nklc7ns926b0rr1aq1069";
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

