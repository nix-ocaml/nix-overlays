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
    url = https://github.com/reasonml/reason/archive/a93c4c3.tar.gz;
    sha256 = "09bs2vkq4rkxv4z564vr4d3d6hd23b118ma72gkmrbc7ldxhj972";
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
