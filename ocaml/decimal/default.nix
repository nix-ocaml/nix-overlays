{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "decimal";
  version = "0.2.0";
  src = builtins.fetchurl {
    url = "https://github.com/yawaramin/ocaml-decimal/releases/download/v${version}/decimal-v${version}.tbz";
    sha256 = "19khc7d4fj7i98nbilniz42912ifwzw49vxb5diy9yzrr2s8wxpg";
  };

  propagatedBuildInputs = [ zarith ];
}
