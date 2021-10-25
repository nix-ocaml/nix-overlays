{ ocamlPackages }:

with ocamlPackages;


buildDunePackage rec {
  pname = "melange-compiler-libs";
  version = "0.0.0";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange-compiler-libs/archive/f10b41fb.tar.gz;
    sha256 = "1sy8r5sq812sf8978f6rwwm8lrxmhayfsbr4v6h9xs8fnnq7yb9k";
  };

  propagatedBuildInputs = [ menhir menhirLib ];
}
