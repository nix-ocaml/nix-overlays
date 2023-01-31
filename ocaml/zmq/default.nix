{ fetchFromGitHub, zeromq, buildDunePackage, dune-configurator, ounit2, stdint }:

buildDunePackage rec {
  pname = "zmq";
  version = "5.2.0";

  src = fetchFromGitHub {
    owner = "issuu";
    repo = "ocaml-zmq";
    rev = "8a24cd042";
    sha256 = "sha256-EZKDSzW08lNgJgtgNOBgQ8ub29pSy2rwcqoMNu+P3kI=";
  };

  nativeBuildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ zeromq stdint ];

  checkInputs = [ ounit2 ];
  doCheck = false;
}
