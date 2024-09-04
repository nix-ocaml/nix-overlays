{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";

  src = builtins.fetchurl {
    url = "https://github.com/anmonteiro/ocaml-h2/releases/download/0.13.0/h2-0.13.0.tbz";
    sha256 = "03q7m2ra6ch49z1vwjbmp4qzr0sv3pl3n8h7lbkr8lhpg3qvd28d";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
