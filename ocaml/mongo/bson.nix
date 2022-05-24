{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "bson";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-mongodb/archive/f491384652eaf24e423204ae79f590bb90fb6506.tar.gz;
    sha256 = "1anklswasz38xyn7k5fznj5985banfkf84si1ajjycx62xqlnr3a";
  };
  version = "0.0.1-dev";

  propagatedBuildInputs = [ angstrom faraday ];
}
