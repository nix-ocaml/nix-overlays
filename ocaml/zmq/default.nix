{ lib, fetchFromGitHub, zeromq, buildDunePackage, dune-configurator, ounit2, stdint }:

buildDunePackage rec {
  pname = "zmq";
  version = "5.2.0";

  src = builtins.fetchurl {
    url = https://github.com/issuu/ocaml-zmq/archive/8a24cd042.tar.gz;
    sha256 = "1siwlpywq7mxfr1lhhlbqp8dh83cxvw7lkqcydk1hhssjy10aq7l";
  };

  nativeBuildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ zeromq stdint ];

  checkInputs = [ ounit2 ];
  doCheck = false;
}
