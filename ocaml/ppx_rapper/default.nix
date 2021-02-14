{ stdenv, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "ppx_rapper";
  version = "3.0.0";

  src = builtins.fetchurl {
    url = "https://github.com/roddyyaga/ppx_rapper/archive/${version}.tar.gz";
    sha256 = "037a3yyjq515qfgvjd99csvl1csgw2nn19dzqihzlb107353qims";
  };

  propagatedBuildInputs = [ caqti pg_query ];
}
