{ ocamlPackages, lib }:

ocamlPackages.buildDunePackage {
  pname = "hashcons";
  version = "1.3";
  src = builtins.fetchurl {
    url = https://github.com/backtracking/ocaml-hashcons/archive/d733325eeb55878bed285120c2c088daf78f0e2b.tar.gz;
    sha256 = "1wddaqgg5qsj6wvhbik54g57662s38nanp6dza39qkzzmsyrmvhp";
  };

  doCheck = true;

  meta = {
    description = "OCaml hash-consing library";
    license = lib.licenses.lgpl21;
  };
}
