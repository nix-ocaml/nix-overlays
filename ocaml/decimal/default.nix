{ buildDunePackage, zarith }:

buildDunePackage {
  pname = "decimal";
  version = "1.0.0";
  src = builtins.fetchurl {
    url = https://github.com/yawaramin/ocaml-decimal/releases/download/v1.0.0/decimal-1.0.0.tbz;
    sha256 = "09b5mrajni1ha39v7zv08w5jjf2mnbsgg3wj3j0mhl9mmcxvwhf6";
  };

  propagatedBuildInputs = [ zarith ];
}
