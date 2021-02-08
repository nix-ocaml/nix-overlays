{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "stringext";
  version = "1.6.0";
  src = builtins.fetchurl {
    url = "https://github.com/rgrinberg/stringext/releases/download/${version}/stringext-${version}.tbz";
    sha256 = "1sh6nafi3i9773j5mlwwz3kxfzdjzsfqj2qibxhigawy5vazahfv";
  };

  checkInputs = [ ounit qtest ];
  doCheck = true;
}
