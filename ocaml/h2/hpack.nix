{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.8.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-h2/archive/aff47b8dd.tar.gz;
    sha256 = "0nl9y8qbznfbxb4g0vxm94ysrb6a02ffdpf6gli2x26wr5w9s6as";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
