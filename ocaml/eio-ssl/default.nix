{ buildDunePackage, ssl, eio_main }:

buildDunePackage {
  pname = "eio-ssl";
  version = "n/a";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/eio-ssl/archive/1d3aaa0b.tar.gz;
    sha256 = "0qx12147vrr5al15s2xmmh27hl763igv8lvwsrf0kjf21mcwvb4q";
  };
  propagatedBuildInputs = [ ssl eio_main ];
}
