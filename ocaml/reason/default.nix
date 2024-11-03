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
    rev = "4b5f46071062fb0da6b0d6660969b03c0ac32a94";
    hash = "sha256-HJVUz1zWkGblRidUqgw7wD9v5jVOR2SUlFn/7TMa3JI=";
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
