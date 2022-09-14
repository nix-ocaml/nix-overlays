{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-h2/archive/ebfab17a16.tar.gz;
    sha256 = "083wdhv1k6491cbwqbq0na552irm3n989ypfc1mf7hvlwi90c3w6";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
