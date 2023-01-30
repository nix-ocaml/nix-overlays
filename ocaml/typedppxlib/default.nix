{ buildDunePackage, ppx_optcomp, ocaml-migrate-types }:

buildDunePackage {
  pname = "typedppxlib";
  version = "n/a";
  src = builtins.fetchurl {
    url = https://github.com/EduardoRFS/typedppxlib/archive/658d0b1.tar.gz;
    sha256 = "1ss31grnaj8qixq84b4vjna326nkz98amkgihmpnld24nbgxxwz6";
  };
  propagatedBuildInputs = [ ppx_optcomp ocaml-migrate-types ];
}
