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
  version = "3.8.2";

  src = fetchFromGitHub {
    owner = "reasonml";
    repo = "reason";
    rev = "698609f5192dfa1313ae2e37e40b7af2e63b5ffc";
    hash = "sha256-bcoFy/RzPMq4/kZXftz9q2Sjrhrml9/UirYWxx1PpMY=";
  };

  propagatedBuildInputs = [
    menhir
    menhirLib
    menhirSdk
    fix
    merlin-extend
    ppx_derivers
    ppxlib
    dune-build-info
  ];

  nativeBuildInputs = [ cppo menhir ];

  useDune2 = true;
  patches = [
    ./patches/0001-rename-labels.patch
  ];

  meta.mainProgram = "refmt";
}
