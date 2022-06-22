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
  version = "3.8.0";

  src = builtins.fetchurl {
    url = https://github.com/reasonml/reason/archive/b3aa77b.tar.gz;
    sha256 = "1vlani83cvfz1jikj35dcwgih2bwixsrcczv5rw81f5j8yzy46an";
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
