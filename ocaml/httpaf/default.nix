{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/httpaf/archive/4167b5d.tar.gz;
    sha256 = "1m88mh1qqqa233p71ajzh0p58ii9fl40bn56c0qx547378xa2g1a";
  };
}
