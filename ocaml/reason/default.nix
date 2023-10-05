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
    rev = "d47e613b736cc25629aabc1c8ef91795e265eacb";
    hash = "sha256-KNxIKaXlHbwN0ae6YwGifHzBQsKNKdTlrGO7JlvDKhg=";
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
