{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-h2/archive/fe8b93b5.tar.gz;
    sha256 = "0xxawjx56xlbi3szjcxk6h3pclrzk807kj9q430k0k3xbn2vqswm";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
