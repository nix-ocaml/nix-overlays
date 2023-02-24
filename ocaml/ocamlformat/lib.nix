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
    url = https://github.com/ocaml-ppx/ocamlformat/releases/download/0.25.0/ocamlformat-0.25.0.tbz;
    sha256 = "1rqn3q0zzq6z1i3n12d2jvk3gix24nwxgqcmlbizprlpymma3k8a";
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
