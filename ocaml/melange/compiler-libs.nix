{ buildDunePackage, menhir, menhirLib }:

buildDunePackage {
  pname = "melange-compiler-libs";
  version = "0.0.0";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange-compiler-libs/archive/83e3017.tar.gz;
    sha256 = "02h0gzhk6bdxy6iarp8lk6yl80cskxiraqmbplpa5nqn7r9h2d3l";
  };

  propagatedBuildInputs = [ menhir menhirLib ];
}
