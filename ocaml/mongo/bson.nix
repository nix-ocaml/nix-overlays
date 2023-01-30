{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "bson";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-mongodb/archive/9062e42.tar.gz;
    sha256 = "1zvj30kqrksqjyc1a014np0z0fiaflq8g4d62ds0ydjrd6s25zv0";
  };
  version = "0.0.1-dev";

  propagatedBuildInputs = [ angstrom faraday ];
}
