{ buildDunePackage, zarith }:

buildDunePackage rec {
  pname = "decimal";
  version = "0.2.1";
  src = builtins.fetchurl {
    url = "https://github.com/yawaramin/ocaml-decimal/releases/download/v${version}/decimal-v${version}.tbz";
    sha256 = "1iwqkx35xaynzx5xwxman10g9wizc3v689kb8r24l6d1lg5in27y";
  };

  propagatedBuildInputs = [ zarith ];
}
