{ buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.8.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-h2/archive/3a8f8986c.tar.gz;
    sha256 = "0mjs399anqspgsby74nakspanpwja9k94fy1vg8jl4rgl9h0iln0";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
