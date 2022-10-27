{ lib, fetchFromGitHub, zeromq, buildDunePackage, dune-configurator, ounit2, stdint }:

buildDunePackage rec {
  pname = "zmq";
  version = "5.2.0";

  src = fetchFromGitHub {
    owner = "issuu";
    repo = "ocaml-zmq";
    rev = version;
    sha256 = "sha256-eKCkqmMFZvpE6z4RYz04PMDxgi3EXgDIyyeLEM48D0E=";
  };

  nativeBuildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ zeromq stdint ];

  checkInputs = [ ounit2 ];
  doCheck = true;
}
