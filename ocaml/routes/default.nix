{ stdenv, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDunePackage rec {
  pname = "routes";
  version = "0.8.0";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/routes/archive/770642fa00189f9bbf2846f9b1af517f3f7c3164.tar.gz;
    sha256 = "147n99gqpa24732w93k33qh9mj6xh35rl36qr66hyy7223fhsis0";
  };
}
