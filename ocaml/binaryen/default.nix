{ lib, pkgs, fetchFromGitHub, buildDunePackage, dune-configurator, js_of_ocaml }:

buildDunePackage rec {
  pname = "binaryen";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "grain-lang";
    repo = "binaryen.ml";
    rev = "v${version}";
    sha256 = "sha256-JqD9RNQ0+Kmv45RF6yqRUKeJvoT3bTIUud5iKlA/ogc=";
  };

  postPatch = ''substituteInPlace src/dune --replace "(libraries libbinaryen.c)" "(c_library_flags -lbinaryen)"'';

  # Only needed for tests
  # nativeBuildInputs = [ dune-configurator js_of_ocaml ];

  propagatedBuildInputs = [ pkgs.binaryen ];

  doCheck = false;
}