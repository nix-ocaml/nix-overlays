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
  version = "0.21.0";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-ppx/ocamlformat/archive/a24034a853e4e71264b2ffcda5db4654ffcb2b5c.tar.gz;
    sha256 = "1wl2fmv4yc1maix387fi73230g6vq96yxv4awikfpld618kb4vxs";
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
    # (if version == "0.20.0" then odoc-parser.override { version = "0.9.0"; } else odoc-parser)
    re
    stdio
    uuseg
    uutf
  ];
}
