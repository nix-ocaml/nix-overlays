{ buildDunePackage, zarith }:

buildDunePackage {
  pname = "decimal";
  version = "1.0.0";
  src = builtins.fetchurl {
    url = https://github.com/yawaramin/ocaml-decimal/releases/download/v1.0.0/decimal-1.0.0.tbz;
    sha256 = "06x69a4dragd5kmm4c276f50878bbysrnlqvima8ix5lkxwnchb0";
  };

  propagatedBuildInputs = [ zarith ];
}
