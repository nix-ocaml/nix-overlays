{ lib, ocamlPackages }:

let
  src = builtins.fetchurl {
    url = https://gitlab.com/nomadic-labs/ringo/-/archive/v0.5/ringo-v0.5.tar.gz;
    sha256 = "0hfi8hyyfmryy6z8sc4y3k6z0xhxvagxzafby8r5826fq271amcb";
  };

in

ocamlPackages.buildDunePackage {
  pname = "ringo";
  version = "0.5.0";
  inherit src;

  propagatedBuildInputs = with ocamlPackages; [
    lwt
  ];

  # tests are broken
  # doCheck = true;

  meta = {
    description = "Caches (bounded-size key-value stores) and other bounded-size stores";
    license = lib.licenses.mit;
  };
}
