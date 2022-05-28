{ buildDunePackage, menhir, menhirLib, ocaml, lib }:

buildDunePackage {
  pname = "melange-compiler-libs";
  version = "0.0.0";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange-compiler-libs/archive/b6db8fa122cd21b17d23e7bc801366d91b40a03f.tar.gz;
    sha256 = "1rmal026xjjlkczg6rmqz3avz1dagwiwv12b2mmrwawz3kx70piv";
  };

  propagatedBuildInputs = [ menhir menhirLib ];
}
