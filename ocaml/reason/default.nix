{ lib
, buildDunePackage
, ocaml
, cppo
, menhir
, menhirLib
, menhirSdk
, fix
, merlin-extend
, ppx_derivers
, result
}:

buildDunePackage rec {
  pname = "reason";
  version = "3.8.1";

  src = builtins.fetchurl {
    url = https://github.com/reasonml/reason/releases/download/3.8.1/reason-3.8.1.tbz;
    sha256 = "0574m374mzjf6qa8zpv5n3j4sgk16423ip764s7i0k1byq4vpkdz";
  };


  propagatedBuildInputs = [
    menhir
    menhirLib
    menhirSdk
    fix
    merlin-extend
    ppx_derivers
    result
  ];

  nativeBuildInputs = [ cppo menhir ];

  useDune2 = true;
  patches = [
    ./patches/0001-rename-labels.patch
  ];

  meta.mainProgram = "refmt";
}
