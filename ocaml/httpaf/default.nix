{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/httpaf/archive/ec21944.tar.gz;
    sha256 = "0iasc1440qpcgx08izjd7wqm9n0ncczx32myxhv9wqa9br78p31y";
  };
}
