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
    url = https://github.com/reasonml/reason/archive/3f909247.tar.gz;
    sha256 = "1d7mzyr186gd8zaa9n2bqjvfhfimifrvksiiq45dz1n8ak9zpgzy";
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
