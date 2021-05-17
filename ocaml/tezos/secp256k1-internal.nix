{ lib, pkgs, ocamlPackages }:

let
  src = builtins.fetchurl {
    url = https://gitlab.com/nomadic-labs/ocaml-secp256k1-internal/-/archive/v0.2/ocaml-secp256k1-internal-v0.2.tar.bz2;
    sha256 = "56a12978d13058761ae495068ad683f1da837b2e280c70b2042c4325926a12f1";
  };

in

ocamlPackages.buildDunePackage {
  pname = "secp256k1-internal";
  version = "0.2.0";
  inherit src;

  checkInputs = with ocamlPackages; [
    alcotest
    hex
  ];

  doCheck = true;

  propagatedBuildInputs = with ocamlPackages; [
    pkgs.gmp
    dune-configurator
    cstruct
    bigstring
  ];

  meta = {
    description = "Library of JSON and binary encoding combinators";
    license = lib.licenses.mit;
  };
}
