{ fetchFromGitHub, buildDunePackage, ppx_optcomp, ocaml-migrate-parsetree-2 }:

buildDunePackage {
  pname = "ocaml-migrate-types";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "EduardoRFS";
    repo = "ocaml-migrate-types";
    rev = "58919cdf10b4e0de46234f19adef6390a215e3e2";
    sha256 = "sha256-X3Gfuelv1ElTLfkCSXlEijKM6KxiP8S0bS5kj76Cxjs=";
  };
  propagatedBuildInputs = [ ppx_optcomp ocaml-migrate-parsetree-2 ];
}
