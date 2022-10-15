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
  version = "3.8.2";

  src = builtins.fetchurl {
    url = https://github.com/reasonml/reason/releases/download/3.8.2/reason-3.8.2.tbz;
    sha256 = "1wifxg0ina3lvy72wxc9hhr49n4fzc8j4wgjmn1fz38bn9fw9p3s";
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
