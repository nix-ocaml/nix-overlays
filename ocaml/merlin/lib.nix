{
  lib,
  ocaml,
  buildDunePackage,
  yojson,
  csexp,
  result,
}:

let
  merlinVersion = "5.8";

  ocamlVersionShorthand = lib.concatStrings (lib.take 2 (lib.splitVersion ocaml.version));

  version = "${merlinVersion}-${ocamlVersionShorthand}";
in

buildDunePackage {
  pname = "merlin-lib";
  version = version;
  src =
    if lib.versionOlder "5.6" ocaml.version then
      builtins.fetchurl {
        url = "https://github.com/ocaml/merlin/releases/download/v5.8.1-506_preview/merlin-5.8.1-506.preview.tbz";
        sha256 = "1k22znd0wy0z6k3mikgifijfxxwx8m05mid0j1mard38dygi0mzg";
      }
    else if lib.versionOlder "5.5" ocaml.version then
      builtins.fetchurl {
        url = "https://github.com/ocaml/merlin/releases/download/v5.8.1-505/merlin-5.8.1-505.tbz";
        sha256 = "10r512l6ps85nxra36bvzpiz4mv0jv5k3j5xsqpsz4n01yy35yxq";
      }
    else if lib.versionOlder "5.4" ocaml.version then
      builtins.fetchurl {
        url = "https://github.com/ocaml/merlin/releases/download/v5.7.1-504/merlin-5.7.1-504.tbz";
        sha256 = "1mbhi4mg07w3za6bm96hk0s4qr9gcj5mpxslbir8pcqlz4y0g6qk";
      }
    else if lib.versionOlder "5.3" ocaml.version then
      builtins.fetchurl {
        url = "https://github.com/ocaml/merlin/releases/download/v5.6-503/merlin-5.6-503.tbz";
        sha256 = "1m629wpiihn61ag90mr3qxf6dgb1hyg0i6mbclzs5xxa584svp5h";
      }
    else if lib.versionOlder "5.2" ocaml.version then
      builtins.fetchurl {
        url = "https://github.com/ocaml/merlin/releases/download/v5.3-502/merlin-5.3-502.tbz";
        sha256 = "1g14maryp5aw02a0chj9xqbdkky125g4y38cxwqnxylp4gqldsic";
      }
    else if lib.versionOlder "5.1" ocaml.version then
      builtins.fetchurl {
        url = "https://github.com/ocaml/merlin/releases/download/v4.17.1-501/merlin-4.17.1-501.tbz";
        sha256 = "0055n11ghrxypd6fjx67fnnwj8csp3jgplsnjiiyj28zhym0frrp";
      }
    else if lib.versionOlder "5.0" ocaml.version then
      builtins.fetchurl {
        url = "https://github.com/ocaml/merlin/releases/download/v4.14-500/merlin-4.14-500.tbz";
        sha256 = "03nps5mbh5lzf88d850903bz75g5sk33qc3zi7c0qlkmz0jg68zc";
      }
    else
      builtins.fetchurl {
        url = "https://github.com/ocaml/merlin/releases/download/v4.19-414/merlin-4.19-414.tbz";
        sha256 = "113kcp9bca7348li0f3gmh6rcicr4c7lvw558xqcxa83jbsk19k0";
      };

  buildInputs = [
    yojson
    csexp
    result
  ];
}
