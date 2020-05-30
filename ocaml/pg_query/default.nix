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
    url = http://github.com/roddyyaga/pg_query-ocaml/archive/bae4c23d4a62f0b0559ed5a8552bf481574250de.tar.gz;
    sha256 = "11vlpv924w8bq7mcimzgwchpfvn39ij6mpzmh2vnqyghmmayxb9z";
  };

  useDune2 = true;

  propagatedBuildInputs = with ocamlPackages; [
    ppx_inline_test
    ppx_deriving
    ctypes
  ];
}
