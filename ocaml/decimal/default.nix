{ buildDunePackage, zarith }:

buildDunePackage {
  pname = "decimal";
  version = "1.0.2";
  src = builtins.fetchurl {
    url = "https://github.com/yawaramin/ocaml-decimal/releases/download/v1.0.2/decimal-1.0.2.tbz";
    sha256 = "0v7y2daqzm4mq7cl16njmkglzan06zm2d2x05i146s8cixdhzfir";
  };

  propagatedBuildInputs = [ zarith ];
}
