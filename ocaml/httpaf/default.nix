{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/httpaf/archive/97692a4.tar.gz;
    sha256 = "1g5m610ap33c4mcc5gzdf7x99kggjl75fwj3jvh8hr2gcc7fdvll";
  };
}
