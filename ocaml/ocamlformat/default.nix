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
  version = "0.22.4";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-ppx/ocamlformat/releases/download/0.22.4/ocamlformat-0.22.4.tbz;
    sha256 = "0q60r7bdl6x9ksbfz8yggxripa4inf0dr9w1ipkc4z5ch4mxwm7b";
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
