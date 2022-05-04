{ buildDunePackage, caqti, pg_query }:

buildDunePackage rec {
  pname = "ppx_rapper";
  version = "3.0.0";

  src = builtins.fetchurl {
    url = https://github.com/roddyyaga/ppx_rapper/archive/aedb7a0d8a263175619c96f9509287526a07fb99.tar.gz;
    sha256 = "0x3k1jna3j5xgfk95lhmjrwwkd2gi8f8py8vx0fn4ddxvfmk0his";
  };

  propagatedBuildInputs = [ caqti pg_query ];
}
