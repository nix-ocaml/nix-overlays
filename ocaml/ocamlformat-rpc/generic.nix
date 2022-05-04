{ lib
, fetchurl
, ocamlformat
, fetchzip
, ocaml-ng
, version
, tarballName ? "ocamlformat-${version}.tbz"
, buildDunePackage
, odoc-parser
, ocamlformat-rpc-lib
, base
, cmdliner_1_0
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
  rpc-lib-legacy = ocamlformat-rpc-lib.overrideAttrs (_: {
    src = builtins.fetchurl {
      sha256 = "sha256-JtmNCgwjbCyUE4bWqdH5Nc2YSit+rekwS43DcviIfgk=";
      url = https://github.com/ocaml-ppx/ocamlformat/releases/download/0.20.0/ocamlformat-0.20.0.tbz;
    };
  });
  rpc-lib = {
    "0.20.0" = rpc-lib-legacy;
    "0.20.1" = rpc-lib-legacy;
    "0.21.0" = ocamlformat-rpc-lib;
  }."${version}";
  cmdliner-lib = {
    "0.20.0" = cmdliner_1_0;
    "0.20.1" = cmdliner_1_0;
    "0.21.0" = cmdliner;
  }."${version}";
  src =
    fetchurl {
      url = "https://github.com/ocaml-ppx/ocamlformat/releases/download/${version}/${tarballName}";
      sha256 = {
        "0.20.0" = "sha256-JtmNCgwjbCyUE4bWqdH5Nc2YSit+rekwS43DcviIfgk=";
        "0.20.1" = "sha256-fTpRZFQW+ngoc0T6A69reEUAZ6GmHkeQvxspd5zRAjU=";
        "0.21.0" = "0b9kaxq66mwdx6g78xdbw8k2gc4pp23rdaphx76g07sqpkv1f61a";
      }."${version}";
    };
in


buildDunePackage {
  pname = "ocamlformat-rpc";
  inherit src version;

  minimumOCamlVersion = "4.08";

  useDune2 = true;

  buildInputs = [
    rpc-lib
    base
    cmdliner-lib
    dune-build-info
    either
    fix
    fpath
    menhir
    menhirLib
    menhirSdk
    ocaml-version
    ocamlformat
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
