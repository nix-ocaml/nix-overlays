{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "bson";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-mongodb/archive/9062e42.tar.gz;
    sha256 = "1yggvmv6a9njyx7na3967fkab0icl7iwnq6b7yhli4sndbgid1y2";
  };
  version = "0.0.1-dev";

  propagatedBuildInputs = [ angstrom faraday ];
}
