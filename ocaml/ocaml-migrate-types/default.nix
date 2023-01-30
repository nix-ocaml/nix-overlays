{ buildDunePackage, ppx_optcomp, ocaml-migrate-parsetree-2 }:

buildDunePackage {
  pname = "ocaml-migrate-types";
  version = "n/a";
  src = builtins.fetchurl {
    url = https://github.com/EduardoRFS/ocaml-migrate-types/archive/58919cdf10b4e0de46234f19adef6390a215e3e2.tar.gz;
    sha256 = "1zhr9g9762n9w56wf0sqpf2kcs312y1rwxl8prp2xl8xs6sijx5y";
  };
  propagatedBuildInputs = [ ppx_optcomp ocaml-migrate-parsetree-2 ];
}
