{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/httpaf/archive/4e3ae8b.tar.gz;
    sha256 = "1cm167jvl81lfzw8fwr4pnl0gr2shr6akpbw29c3kafifsmyca4a";
  };
}
