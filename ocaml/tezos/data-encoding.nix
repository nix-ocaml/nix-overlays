{ lib, ocamlPackages }:

let
  src = builtins.fetchurl {
    url = https://gitlab.com/nomadic-labs/data-encoding/-/archive/v0.4/data-encoding-v0.4.tar.gz;
    sha256 = "1nlg8bm5yh107jbaba5rplr31iz3pafaqqaqsb626cb09z408ddz";
  };

in

ocamlPackages.buildDunePackage {
  pname = "data-encoding";
  version = "0.4.0";
  inherit src;

  buildInputs = with ocamlPackages; [
    alcotest
    crowbar
  ];

  doCheck = true;

  propagatedBuildInputs = with ocamlPackages; [
    ezjsonm
    zarith
    hex
    json-data-encoding
    json-data-encoding-bson
  ];

  meta = {
    description = "Library of JSON and binary encoding combinators";
    license = lib.licenses.mit;
  };
}
