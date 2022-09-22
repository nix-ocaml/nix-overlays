{ buildDunePackage, caqti, pg_query }:

buildDunePackage rec {
  pname = "ppx_rapper";
  version = "3.0.0";

  src = builtins.fetchurl {
    url = https://github.com/roddyyaga/ppx_rapper/archive/6fb81693.tar.gz;
    sha256 = "10mmj8rnvpraqnfmqxl7pbrrqff1rxq2zrbvxxn8g46yxdlcjbkn";
  };

  propagatedBuildInputs = [ caqti pg_query ];
}
