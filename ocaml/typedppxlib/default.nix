{ buildDunePackage, ppx_optcomp, ocaml-migrate-types }:

buildDunePackage {
  pname = "typedppxlib";
  version = "n/a";
  src = builtins.fetchurl {
    url = https://github.com/EduardoRFS/typedppxlib/archive/658d0b1.tar.gz;
    sha256 = "0idkbc8pr4hms29fpq1pa870c4wqs3zjm6gpcsna4qv56v1c756p";
  };
  propagatedBuildInputs = [ ppx_optcomp ocaml-migrate-types ];
}
