{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-h2/archive/a5f7eebf3.tar.gz;
    sha256 = "1fm1mradpvzx5xnpw5q664vc73k40micrdz5x3xzpiikr86ki33p";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
