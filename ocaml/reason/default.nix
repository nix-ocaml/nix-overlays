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
  version = "3.9.0";

  src = fetchFromGitHub {
    owner = "reasonml";
    repo = "reason";
    rev = "a2203e09d474db82adec72edff31abb8dc77656d";
    hash = "sha256-KSX4feOWkIJDxQ2YC0XZ4wAXS9aqs0Un6JCyCBT6WFM=";
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
