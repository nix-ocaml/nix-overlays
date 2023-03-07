{ buildDunePackage
, base
, camlp-streams
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
, result
, stdio
, uuseg
, uutf
}:

let
in

buildDunePackage {
  pname = "ocamlformat-lib";
  version = "0.25.1";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-ppx/ocamlformat/releases/download/0.25.1/ocamlformat-0.25.1.tbz;
    sha256 = "0gfkdwd29qnrvf9x5b58wkvbvn0f6sxj69nbr8v0p4x31hrjm3yw";
  };

  minimumOCamlVersion = "4.08";
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
    stdio
    uuseg
    uutf
    camlp-streams
    result
  ];
}
