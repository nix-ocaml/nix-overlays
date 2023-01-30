{ buildDunePackage, caqti, pg_query }:

buildDunePackage rec {
  pname = "ppx_rapper";
  version = "3.0.0";

  src = builtins.fetchurl {
    url = https://github.com/roddyyaga/ppx_rapper/archive/8e1dfc4.tar.gz;
    sha256 = "0njnkqck2m8wr80f92xbbdbv571ljxl29j2mfqc3w1k8nagxanl3";
  };

  propagatedBuildInputs = [ caqti pg_query ];
}
