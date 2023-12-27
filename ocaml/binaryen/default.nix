{ lib, pkgs, fetchFromGitHub, buildDunePackage, dune-configurator, js_of_ocaml }:

buildDunePackage rec {
  pname = "binaryen";
  version = "0.24.0";

  src = fetchFromGitHub {
    owner = "grain-lang";
    repo = "binaryen.ml";
    rev = "v${version}";
    hash = "sha256-TE0EXojbKcNmNIvFDLtoUDgqbNEdFillPuTgEN4gmaI=";
  };

  postPatch = ''substituteInPlace src/dune --replace "(libraries libbinaryen.c)" "(c_library_flags -lbinaryen)"'';

  # Only needed for tests
  # nativeBuildInputs = [ dune-configurator js_of_ocaml ];

  propagatedBuildInputs = [ pkgs.binaryen ];

  doCheck = false;
}
