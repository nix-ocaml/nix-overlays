{ buildDunePackage, menhir, menhirLib, ocaml, lib }:

buildDunePackage {
  pname = "melange-compiler-libs";
  version = "0.0.0";

  src = builtins.fetchurl {
    url = https://github.com/melange-re/melange-compiler-libs/archive/2fac95b0ea97fb676240662aeeec8c6f6495dd9c.tar.gz;
    sha256 = "10ija6y9c65h4lzlgnps4514qbbww2r5f566wz83qxwqhaysb3wb";
  };

  propagatedBuildInputs = [ menhir menhirLib ];
}
