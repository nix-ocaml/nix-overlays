{ stdenv, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "ppx_rapper";
  version = "3.0.0";

  src = builtins.fetchurl {
    url = "https://github.com/roddyyaga/ppx_rapper/archive/${version}.tar.gz";
    sha256 = "077hr85nq2jmisdhgw1py6b2418ca8iwjy50aq6m75c24y1730xk";
  };

  propagatedBuildInputs = [ caqti pg_query ];
}
