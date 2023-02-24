{ buildDunePackage
, ocamlformat-lib
, cmdliner
, csexp
, re
, odoc
}:

let
in

buildDunePackage {
  pname = "ocamlformat";
  inherit (ocamlformat-lib) src version;

  minimumOCamlVersion = "4.08";
  strictDeps = true;

  propagatedBuildInputs = [
    csexp
    ocamlformat-lib
    cmdliner
    re
    odoc
  ];
}
