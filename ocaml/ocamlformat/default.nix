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
    url = https://github.com/ocaml-ppx/ocamlformat/archive/1cb060b.tar.gz;
    sha256 = "181k9dwsn26g7akmfwnyj9x0bz5dwdqj9lbllni5dg13cdl0y8pr";
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
