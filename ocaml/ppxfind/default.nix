{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "ppxfind";
  version = "1.4";
  src = builtins.fetchurl {
    url = https://github.com/diml/ppxfind/releases/download/1.4/ppxfind-1.4.tbz;
    sha256 = "0wa9vcrc26kirc2cqqs6kmarbi8gqy3dgdfiv9y7nzsgy1liqacq";
  };

  useDune2 = true;
  buildInputs = [ ocaml-migrate-parsetree ];

  # Don't run the native `strip' when cross-compiling.
  dontStrip = stdenv.hostPlatform != stdenv.buildPlatform;
}
