{ ocamlPackages }:

with ocamlPackages;

let
  buildTls = args: buildDunePackage ({
    version = "0.11.1";
    src = builtins.fetchurl {
      url = https://github.com/mirleft/ocaml-tls/releases/download/v0.11.1/tls-v0.11.1.tbz;
      sha256 = "0ms13fbaxgmpbviazlfa4hb7nmi7s22nklc7ns926b0rr1aq1069";
    };
  } // args);

in rec {
  tls = buildTls {
    pname = "tls";
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
      lwt4
      ptime
    ];
  };

  tls-mirage = buildTls {
    pname = "tls-mirage";
    propagatedBuildInputs = [
      tls
      x509
      fmt
      lwt4
      mirage-flow
      mirage-kv
      mirage-clock
      ptime
      mirage-crypto
      mirage-crypto-pk
    ];
  };
}

