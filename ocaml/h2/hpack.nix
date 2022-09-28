{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-h2/archive/c736ca59.tar.gz;
    sha256 = "15frl9iw7vnp6cd9r6das39wij39c2536ydcw6b5bhwhjsbrgj67";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
