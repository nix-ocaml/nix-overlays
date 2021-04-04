{ stdenv, opaline, ocamlPackages, lib, dune_2, nodejs, gnutar, fetchFromGitHub }:

with ocamlPackages;

buildDunePackage {
  pname = "ppx_jsx_embed";
  version = "0.0.0";
  src = builtins.fetchurl {
    url = https://github.com/melange-re/ppx_jsx_embed/archive/2aa5e28.tar.gz;
    sha256 = "007y6xg1c0ivqhxv8r1ndnnr24savaw5gkg9z1q5ycfp8i0zjagb";
  };
  doCheck = true;
  useDune2 = true;
  propagatedBuildInputs = [ reason ppxlib ];
}
