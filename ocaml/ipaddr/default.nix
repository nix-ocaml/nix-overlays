{ ocamlPackages }:

with ocamlPackages;

let
  buildIpaddr = args: buildDunePackage ({
    version = "4.0.0";
    src = builtins.fetchurl {
      url = https://github.com/mirage/ocaml-ipaddr/releases/download/v4.0.0/ipaddr-v4.0.0.tbz;
      sha256 = "0agwb4dy5agwviz4l7gpv280g1wcgfl921k1ykfwq80b46fbyjkg";
    };
  } // args);
in rec {
  macaddr = buildIpaddr {
    pname = "macaddr";
  };

  macaddr-sexp = buildIpaddr {
    pname = "macaddr-sexp";
    propagatedBuildInputs = [ macaddr ppx_sexp_conv ];
  };

  macaddr-cstruct = buildIpaddr {
    pname = "macaddr-cstruct";
    propagatedBuildInputs = [ macaddr cstruct ];
  };

  ipaddr = buildIpaddr {
    pname = "ipaddr";
    propagatedBuildInputs = [ macaddr stdlib-shims domain-name ];
  };

  ipaddr-sexp = buildIpaddr {
    pname = "ipaddr-sexp";
    propagatedBuildInputs = [ ipaddr ppx_sexp_conv ];
  };

  ipaddr-cstruct = buildIpaddr {
    pname = "ipaddr-cstruct";
    propagatedBuildInputs = [ ipaddr cstruct ];
  };
}
