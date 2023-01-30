{ lib, fetchFromGitHub, zeromq, buildDunePackage, dune-configurator, ounit2, stdint }:

buildDunePackage rec {
  pname = "zmq";
  version = "5.2.0";

  src = builtins.fetchurl {
    url = https://github.com/issuu/ocaml-zmq/archive/8a24cd042.tar.gz;
    sha256 = "10pnynkzm3rqsk0dsc37bnffx9w2rhakhjxmn2lb31iq1fl5wdsz";
  };

  nativeBuildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ zeromq stdint ];

  checkInputs = [ ounit2 ];
  doCheck = false;
}
