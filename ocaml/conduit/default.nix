{ ocamlPackages }:

with ocamlPackages;

let
  buildConduit = args: buildDunePackage ({
    version = "2.2.0";
    src = builtins.fetchurl {
      url = https://github.com/mirage/ocaml-conduit/releases/download/v2.2.0/conduit-v2.2.0.tbz;
      sha256 = "0xvkah2x8ssiij5l9kzqc1wikga6j23kzgsp8xj7d3bz7zkkhr8j";
    };
  } // args);
in rec {
  conduit = buildConduit {
    pname = "conduit";
    propagatedBuildInputs = [
      ppx_sexp_conv
      sexplib
      astring
      uri
      logs
      ipaddr
      ipaddr-sexp
    ];
  };

  conduit-lwt = buildConduit {
    pname = "conduit-lwt";
    propagatedBuildInputs = [
      ppx_sexp_conv
      sexplib
      conduit
      lwt4
    ];
  };

  conduit-lwt-unix = buildConduit {
    pname = "conduit-lwt-unix";
    propagatedBuildInputs = [
      ppx_sexp_conv
      conduit-lwt
      lwt4
      uri
      ipaddr
      ipaddr-sexp
    ];
  };

  conduit-mirage = buildConduit {
    pname = "conduit-mirage";
    propagatedBuildInputs = [
      ppx_sexp_conv
      sexplib
      cstruct
      mirage-stack
      mirage-clock
      mirage-flow
      mirage-flow-combinators
      mirage-random
      dns-client
      conduit-lwt
      vchan
      xenstore
      tls
      tls-mirage
      ipaddr
      ipaddr-sexp
    ];
  };


}
