{ ocamlPackages }:

with ocamlPackages;

let buildLspPkg = args : ocamlPackages.buildDunePackage (rec {
  version = "1.4.0";

  src = builtins.fetchurl {
    url = https://github.com/ocaml/ocaml-lsp/archive/1.4.0.tar.gz;
    sha256 = "2a389b914825a700d657604e585e2bee1171476c98a3096a4b9ccacb1c6d868e";
  };
} // args);

in {
  jsonrpc = buildLspPkg {
    pname = "jsonrpc";

    propagatedBuildInputs = [
      yojson
      ppx_yojson_conv_lib
    ];
  };

  lsp = buildLspPkg {
    pname = "lsp";

    propagatedBuildInputs = [
      jsonrpc
      yojson
      ppx_yojson_conv_lib
      uutf
      csexp
    ];

    buildInputs = [
      cppo
    ];
  };

  lspServer = buildLspPkg {
    pname = "lsp-server";

    propagatedBuildInputs = [
      yojson
      ppx_yojson_conv_lib
      dot-merlin-reader
      dune-build-info
      uutf
      csexp
      ocamlfind
    ];

    buildInputs = [
      cppo
    ];
  };
}
