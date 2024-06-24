{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/ocaml-h2/releases/download/0.12.0/h2-0.12.0.tbz;
    sha256 = "1ijkijpk5ss9d2dn2myrqp1k2qc67ycvvix834v3islh7l8hpr1n";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
