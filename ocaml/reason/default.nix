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
    rev = "f32f244df217b5a140d401b9b0950dc163ded808";
    hash = "sha256-CR/LE05J4/0GHjsWkGSReIW4twLzX6CTD2RmbYVmA5M=";
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
