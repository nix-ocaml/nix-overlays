{ lib
, fetchFromGitHub
, buildDunePackage
, ocaml
, cppo
, menhir
, menhirLib
, menhirSdk
, fix
, merlin-extend
, ppx_derivers
, ppxlib
, dune-build-info
}:

buildDunePackage rec {
  pname = "reason";
  version = "3.9.0-dev+ppxlib";

  src = fetchFromGitHub {
    owner = "reasonml";
    repo = "reason";
    rev = "6401d10f2d1e2c8e1973c0de61d3c27d70b37248";
    hash = "sha256-QJORWjqGuz6pLhZTFLhWxofDsa4dAquVtwhdbGrv0pE=";
  };

  propagatedBuildInputs = [
    menhirLib
    menhirSdk
    fix
    merlin-extend
    ppx_derivers
    ppxlib
    dune-build-info
  ];

  nativeBuildInputs = [ cppo menhir ];

  patches = [
    ./patches/0001-rename-labels.patch
  ];

  meta.mainProgram = "refmt";
}
