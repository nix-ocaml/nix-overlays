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
    owner = "reasonml";
    repo = "reason";
    rev = "f92f7ecc228d19ebf4d9d0214792da7b45472766";
    hash = "sha256-b1kXUOmqUhJrXG42GFAS7QUFTzQ2sNrAUm6/bDQwPTU=";
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
