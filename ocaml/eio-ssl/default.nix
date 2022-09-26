{ buildDunePackage, ssl, eio_main }:

buildDunePackage {
  pname = "eio-ssl";
  version = "n/a";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/eio-ssl/archive/8b3b983.tar.gz;
    sha256 = "0c0aglyga5illjbqnfds5vfcyvx1qd3rvvja038rm8y7cqp37v5m";
  };
  propagatedBuildInputs = [ ssl eio_main ];
}
