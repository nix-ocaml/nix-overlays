{ buildDunePackage, ssl, eio_main }:

buildDunePackage {
  pname = "eio-ssl";
  version = "n/a";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/eio-ssl/archive/5316c2a2.tar.gz;
    sha256 = "0vj63w28c7i15241mzr8ih99l4mr6ankswpiv05z8g3n58670fzx";
  };
  propagatedBuildInputs = [ ssl eio_main ];
}
