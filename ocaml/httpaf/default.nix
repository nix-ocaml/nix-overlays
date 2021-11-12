{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  version = "0.7.0-dev";
  pname = "httpaf";
  propagatedBuildInputs = [ angstrom faraday ];
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/httpaf/archive/3a74fd88.tar.gz;
    sha256 = "1vrkfaknb6za83zmz6q4hrk66bin3gam5880nb7lh98aynswgmll";
  };
}
