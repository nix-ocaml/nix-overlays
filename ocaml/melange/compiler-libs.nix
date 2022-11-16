{ buildDunePackage, menhir, menhirLib, ocaml, lib }:

buildDunePackage {
  pname = "melange-compiler-libs";
  version = "0.0.0";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange-compiler-libs/archive/12e89a7.tar.gz;
    sha256 = "0aphha021wkqfwswian4iyys5hbbhwq1sqiaz086pl08m4162hic";
  };
  propagatedBuildInputs = [ menhir menhirLib ];
}
