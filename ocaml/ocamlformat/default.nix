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
  version = "0.24.1";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-ppx/ocamlformat/releases/download/0.24.1/ocamlformat-0.24.1.tbz;
    sha256 = "1kj1ykax4150i1z801bxjnllkhb6lyj728vvad8fm04gh7ljad02";
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
