{ lib, fetchFromGitHub, zeromq, buildDunePackage, dune-configurator, ounit2, stdint }:

buildDunePackage {
  pname = "zmq";
  version = "5.1.5";

  src = fetchFromGitHub {
    owner = "issuu";
    repo = "ocaml-zmq";
    rev = "5.1.5";
    sha256 = "sha256-rW6WoOv6GaRAzY0XXZ/XhospLl1oYAxzzTyIUhrk1Bg=";
  };

  nativeBuildInputs = [
    dune-configurator
  ];

  propagatedBuildInputs = [
    zeromq
    stdint
  ];

  checkInputs = [
    ounit2
  ];

  doCheck = false;
}
