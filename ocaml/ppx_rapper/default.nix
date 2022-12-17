{ buildDunePackage, caqti, pg_query }:

buildDunePackage rec {
  pname = "ppx_rapper";
  version = "3.0.0";

  src = builtins.fetchurl {
    url = https://github.com/roddyyaga/ppx_rapper/archive/8e1dfc4.tar.gz;
    sha256 = "17y7i5i1sxhq9wpj2y3zd803sn23kx023nik6jskq0385xzwpvj7";
  };

  propagatedBuildInputs = [ caqti pg_query ];
}
