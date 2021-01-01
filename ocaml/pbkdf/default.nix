{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "pbkdf";
  version = "1.1.0";
  src = builtins.fetchurl {
    url = "https://github.com/abeaumont/ocaml-pbkdf/releases/download/${version}/${pname}-${version}.tbz";
    sha256 = "0r120hysfn4kbbwwv6j7si8avjcbakxi071lia2hqjdzkayx2gp5";
  };

  propagatedBuildInputs = [
    mirage-crypto
  ];

  checkInputs = [ alcotest ];
}

