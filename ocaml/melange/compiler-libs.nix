{ ocamlPackages }:

with ocamlPackages;


buildDunePackage rec {
  pname = "melange-compiler-libs";
  version = "0.0.0";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange-compiler-libs/archive/c787d2f98a.tar.gz;
    sha256 = "0qp2xfcbbfsghf8biqwhhws2pnsmwd55xhjc2g3y354mpl41y2j4";
  };

  propagatedBuildInputs = [ menhir menhirLib ];
}
