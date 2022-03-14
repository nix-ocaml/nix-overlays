{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.8.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-h2/archive/e1cc2dc.tar.gz;
    sha256 = "0j03alnhai2l5apc1v6lnw2kg3hpzjs5sng11b60myxwbqkn8bfy";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
