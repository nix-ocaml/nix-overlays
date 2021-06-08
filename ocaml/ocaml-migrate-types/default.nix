{ stdenv, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "ocaml-migrate-types";
  version = "0.0.1-dev";

  src = builtins.fetchurl {
    url = "https://github.com/EduardoRFS/ocaml-migrate-types/archive/a796a0224390c8d77973c5cf0ebf0ff1c697980e.tar.gz";
    sha256 = "1nm5c67hvinr6absbi11x3phmg2gg39wrq94jyvw4whfv1hq30i2";
  };

  propagatedBuildInputs = [ ppx_optcomp ocaml-migrate-parsetree ];
}
