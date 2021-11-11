{ buildDunePackage, menhir, menhirLib }:

buildDunePackage {
  pname = "melange-compiler-libs";
  version = "0.0.0";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange-compiler-libs/archive/78a33622.tar.gz;
    sha256 = "015gqgq5b9kdpw0y5hwhcj8wxl72rqh13d3g4w36yp24kxh05c88";
  };

  propagatedBuildInputs = [ menhir menhirLib ];
}
