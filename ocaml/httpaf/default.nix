{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/httpaf/archive/99809b209.tar.gz;
    sha256 = "0rq7ny6b6lq9vybxk9wdgxlbx0jsgrp58iil664jvlafymr83kqz";
  };
}
