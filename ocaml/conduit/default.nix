{ ocamlPackages }:

with ocamlPackages;

let
  buildConduit = args: buildDunePackage ({
    version = "2.1.0";
    src = builtins.fetchurl {
      url = https://github.com/mirage/ocaml-conduit/archive/17455d93711402ac39f1472da1c50a25303fd414.tar.gz;
      sha256 = "08r3847ss2yclzhb5bmghq1wrzqxk1jh5f8mjxwg543kn56h1zr3";
    };
    # src = builtins.fetchurl {
      # url = https://github.com/mirage/ocaml-conduit/releases/download/v2.1.0/conduit-v2.1.0.tbz;
      # sha256 = "0wkyyzc194x1cvb7khxjzkf0jch5m7y6bmxmq5vxrm3yrbxd2kbv";
    # };
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
