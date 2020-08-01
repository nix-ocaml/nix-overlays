{ stdenv, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "ppx_rapper";
  version = "1.1.0-dev";

  src = builtins.fetchurl {
    url = https://github.com/roddyyaga/ppx_rapper/archive/2.0.0.tar.gz;
    sha256 = "1ijg852471hhihl7km58mkkkhnjnr21ihpfrxw1cn3jmv3scdd29";
  };

  useDune2 = true;

  propagatedBuildInputs = with ocamlPackages; [
    caqti
    caqti-lwt
    base
    pg_query
  ];
}
