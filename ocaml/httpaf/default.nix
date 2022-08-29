{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/httpaf/archive/ef1a7119.tar.gz;
    sha256 = "0ah2mvcih1j52l5d7xkjrqhzzdq542vln0qs3gap62lwrn4xsrm0";
  };
}
