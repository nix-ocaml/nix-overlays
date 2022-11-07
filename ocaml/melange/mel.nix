{ buildDunePackage
, cmdliner
, melange
, luv
, cppo
, ocaml-migrate-parsetree-2
}:

buildDunePackage {
  pname = "mel";
  inherit (melange) src version;

  nativeBuildInputs = [ cppo ];
  propagatedBuildInputs = [
    cmdliner
    luv
    ocaml-migrate-parsetree-2
    melange
  ];
}
