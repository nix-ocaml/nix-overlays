{ buildDunePackage, ssl, eio_main }:

buildDunePackage {
  pname = "eio-ssl";
  version = "n/a";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/eio-ssl/archive/dd736422.tar.gz;
    sha256 = "168wsx8h0l10hvilh4mmazzv225pffabijpy4b6yxzx1dh256n6n";
  };
  propagatedBuildInputs = [ ssl eio_main ];
}
