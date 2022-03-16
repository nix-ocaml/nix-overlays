{ buildDunePackage, caqti, pg_query }:

buildDunePackage rec {
  pname = "ppx_rapper";
  version = "3.0.0";

  src = builtins.fetchurl {
    url = https://github.com/roddyyaga/ppx_rapper/archive/4a8c77343fd35cedaf592f47b10c41ca0dea8b3b.tar.gz;
    sha256 = "0gfj2yl71xymxhfzj8sa1mm0aljkzivyyx6dkkqdsjm8c0fidvxc";
  };

  propagatedBuildInputs = [ caqti pg_query ];
}
