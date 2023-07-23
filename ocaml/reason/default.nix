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
    rev = "03f588e1c91f232763ac6ca5312aa790f5c24680";
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
