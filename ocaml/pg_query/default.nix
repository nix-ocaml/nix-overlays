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
    url = https://github.com/roddyyaga/pg_query-ocaml/archive/0.9.5.tar.gz;
    sha256 = "1kjj02y9k7hxj76xr3kbdxw2nk2pw80mvmc8hixw62bb9riapm4x";
  };

  useDune2 = true;

  propagatedBuildInputs = with ocamlPackages; [
    ppx_inline_test
    ppx_deriving
    ctypes
  ];
}
