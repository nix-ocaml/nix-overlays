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
  version = "3.12.0";

  src = fetchFromGitHub {
    owner = "reasonml";
    repo = "reason";
    rev = "18978b4adf2938a4053c41e7079c57a1df8ec066";
    hash = "sha256-fnoPkXCCZgtvNdXcfOFxxswfYdT0QTi1+zVi6Fs8ajg=";
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
