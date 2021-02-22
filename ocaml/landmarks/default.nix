{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "landmarks";
  version = "1.3";
  src = builtins.fetchurl {
    url = https://github.com/LexiFi/landmarks/releases/download/v1.3/landmarks-v1.3.tbz;
    sha256 = "0iwd8h7kfd0ccdx2wpw718b5mdvlp5wgs94c71ramnxs60acs5nn";
  };

  propagatedBuildInputs = [
    ocaml-migrate-parsetree
  ];
}
