{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "pg_query";
  version = "0.9.4-dev";

  unpackPhase = ''
    runHook preUnpack
    tar -xzf $src --strip-components=1 --exclude='bin'
    runHook postUnpack
  '';

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/pg_query-ocaml/archive/fe2228611f1824e54694d2c48ce4f118e5b40cb3.tar.gz;
    sha256 = "0ma5wkhfsdvvshnk2q9kwwnjagkfls1xxpznpf69vljkxynhmpr1";
  };

  useDune2 = true;

  propagatedBuildInputs = with ocamlPackages; [
    ppx_inline_test
    ppx_deriving
    ctypes
  ];
}
