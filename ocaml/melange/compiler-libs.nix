{ buildDunePackage, menhir, menhirLib, ocaml, lib }:

buildDunePackage {
  pname = "melange-compiler-libs";
  version = "0.0.0";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange-compiler-libs/archive/029354b.tar.gz;
    sha256 = "1xvyx4c7df1wwchvnarq70grq6wk5lbhhcldq0rrid2fkabr96kf";
  };
  propagatedBuildInputs = [ menhir menhirLib ];
}
