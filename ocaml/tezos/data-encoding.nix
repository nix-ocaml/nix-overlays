{ lib, ocamlPackages }:

let
  src = builtins.fetchurl {
    url = https://gitlab.com/nomadic-labs/data-encoding/-/archive/0.3/data-encoding-0.3.tar.gz;
    sha256 = "185i5iyya0d2n3818hd758zrf0pbc234j915lahri355xa6167c7";
  };

in

ocamlPackages.buildDunePackage {
  pname = "data-encoding";
  version = "0.3.0";
  inherit src;

  propagatedBuildInputs = with ocamlPackages; [
    ezjsonm
    zarith
    json-data-encoding
    json-data-encoding-bson
    alcotest
    crowbar
  ];

  meta = {
    description = "Library of JSON and binary encoding combinators";
    license = lib.licenses.mit;
  };
}
