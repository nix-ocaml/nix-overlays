{ lib
, fetchurl
, fetchzip
, ocaml-ng
, version
, tarballName ? "ocamlformat-${version}.tbz"
, buildDunePackage
, odoc-parser
, ocamlformat-rpc-lib
, base
, cmdliner
, dune-build-info
, either
, fix
, fpath
, menhir
, menhirLib
, menhirSdk
, ocaml-version
, ocp-indent
, re
, stdio
, uuseg
, uutf
, result
}:

let
  src =
    fetchurl {
      url = "https://github.com/ocaml-ppx/ocamlformat/releases/download/${version}/${tarballName}";
      sha256 = {
        "0.20.0" = "sha256-JtmNCgwjbCyUE4bWqdH5Nc2YSit+rekwS43DcviIfgk=";
        "0.20.1" = "sha256-fTpRZFQW+ngoc0T6A69reEUAZ6GmHkeQvxspd5zRAjU=";
      }."${version}";
    };
in


buildDunePackage {
  pname = "ocamlformat-rpc";
  inherit src version;

  minimumOCamlVersion = "4.08";

  useDune2 = true;

  buildInputs = [
    ocamlformat-rpc-lib
    base
    cmdliner
    dune-build-info
    either
    fix
    fpath
    menhir
    menhirLib
    menhirSdk
    ocaml-version
    ocp-indent
    (if version == "0.20.0" then odoc-parser.override { version = "0.9.0"; } else odoc-parser)
    re
    stdio
    uuseg
    uutf
  ];

  postPatch = ''
    substituteInPlace "vendor/parse-wyc/menhir-recover/emitter.ml" --replace \
      "String.capitalize" "String.capitalize_ascii"
  '';

  meta = {
    homepage = "https://github.com/ocaml-ppx/ocamlformat";
    description = "Auto-formatter for OCaml code, RPC interface";
    maintainers = [ lib.maintainers.ulrikstrid ];
    license = lib.licenses.mit;
  };
}
