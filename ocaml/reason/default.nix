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
  version = "3.10.0";

  src = fetchFromGitHub {
    # https://github.com/reasonml/reason/pull/2734
    owner = "reasonml";
    repo = "reason";
    rev = "d4a8d70b0403c5b0afc38f5bf3e5b0e0d726dee3";
    hash = "sha256-hnGRI/BNWeL4q9UZaSxScRNPgZgnL/psVZO4kArBATY=";
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
