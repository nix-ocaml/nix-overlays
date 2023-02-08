{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "bson";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-mongodb";
    rev = "9062e42";
    sha256 = "sha256-Wxyd2h7jcP2EkYafxhi5HwTnS5UdE0InCpfSnZmj8Dw=";
  };
  version = "0.0.1-dev";

  propagatedBuildInputs = [ angstrom faraday ];
}
