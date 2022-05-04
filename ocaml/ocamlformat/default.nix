{ lib
, buildDunePackage
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
, odoc-parser
  # (if version == "0.20.0" then odoc-parser.override { version = "0.9.0"; } else odoc-parser)
, re
, stdio
, uuseg
, uutf
}:

let
  version = "0.21.0";
  src = builtins.fetchurl {
    url = "https://github.com/ocaml-ppx/ocamlformat/releases/download/${version}/ocamlformat-${version}.tbz";
    sha256 = "0b9kaxq66mwdx6g78xdbw8k2gc4pp23rdaphx76g07sqpkv1f61a";
  };
in

buildDunePackage {
  pname = "ocamlformat";
  inherit src version;

  minimumOCamlVersion =
    if lib.versionAtLeast version "0.17.0"
    then "4.08"
    else "4.06";

  useDune2 = true;

  strictDeps = true;

  nativeBuildInputs = [
    menhir
  ];

  propagatedBuildInputs = [
    base
    cmdliner
    dune-build-info
    either
    fix
    fpath
    menhirLib
    menhirSdk
    ocaml-version
    ocp-indent
    odoc-parser
    # (if version == "0.20.0" then odoc-parser.override { version = "0.9.0"; } else odoc-parser)
    re
    stdio
    uuseg
    uutf
  ];
}
