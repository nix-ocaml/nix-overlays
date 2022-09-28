{ buildDunePackage, ssl, eio_main }:

buildDunePackage {
  pname = "eio-ssl";
  version = "n/a";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/eio-ssl/archive/7aefffb.tar.gz;
    sha256 = "0s457k48midisizara20hq5awfq4jql1rp1rp8hpj4snwy6l592g";
  };
  propagatedBuildInputs = [ ssl eio_main ];
}
