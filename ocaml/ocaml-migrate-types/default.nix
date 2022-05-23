{ buildDunePackage, ppx_optcomp, ocaml-migrate-parsetree-2 }:

buildDunePackage {
  pname = "ocaml-migrate-types";
  version = "n/a";
  src = builtins.fetchurl {
    url = https://github.com/EduardoRFS/ocaml-migrate-types/archive/58919cdf10b4e0de46234f19adef6390a215e3e2.tar.gz;
    sha256 = "0azspiv7sjs6kjl0asi7lcs9c2yv4lg386qx3r2qsvgm2nqh0d2x";
  };
  propagatedBuildInputs = [ ppx_optcomp ocaml-migrate-parsetree-2 ];
}
