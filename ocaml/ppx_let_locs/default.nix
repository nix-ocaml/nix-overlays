{ stdenv, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "ppx_let_locs";
  version = "0.0.1-dev";

  src = builtins.fetchurl {
    url = "https://github.com/EduardoRFS/ppx_let_locs/archive/12f6bba19a4e2af56671211ba0f8ce9b83f18819.tar.gz";
    sha256 = "0jlrnq9b1p8qp1mc7bf65a4prr1ww39a8qj3nxmpd3b8yal9c23q";
  };

  propagatedBuildInputs = [ reason ppxlib ppx_optcomp ocaml-migrate-types ];
}
