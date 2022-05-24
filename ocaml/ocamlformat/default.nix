{ lib
, buildDunePackage
, base
, csexp
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
, odoc-parser
  # (if version == "0.20.0" then odoc-parser.override { version = "0.9.0"; } else odoc-parser)
, re
, stdio
, uuseg
, uutf
}:

let
in

buildDunePackage {
  pname = "ocamlformat";
  version = "0.22.2";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-ppx/ocamlformat/releases/download/0.22.2/ocamlformat-0.22.2.tbz;
    sha256 = "0gqc8piq2fcm682bjk0xj2rysd9idjr6arxqf9a9gn3mx3yfc838";
  };

  minimumOCamlVersion = "4.08";
  strictDeps = true;

  nativeBuildInputs = [
    menhir
  ];

  propagatedBuildInputs = [
    base
    cmdliner
    csexp
    dune-build-info
    either
    fix
    fpath
    menhirLib
    menhirSdk
    ocaml-version
    ocp-indent
    odoc-parser
    re
    stdio
    uuseg
    uutf
  ];
}
