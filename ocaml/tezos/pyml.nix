{ lib, pkgs, ocamlPackages }:

with ocamlPackages;

let
  src = builtins.fetchurl {
    url = https://github.com/thierry-martinez/pyml/archive/20210226.tar.gz;
    sha256 = "0nafp4gk10f74qx1xs0rc6fin332zqqryyy0xlmh3wf4p3680pcq";
  };

in

buildDunePackage {
  pname = "pyml";
  version = "20210226";
  inherit src;

  propagatedBuildInputs = [
    stdcompat
    pkgs.python3
  ];

  checkInputs = [
    stdcompat
  ];

  # tests are broken
  # doCheck = true;

  meta = {
    description = "Caches (bounded-size key-value stores) and other bounded-size stores";
    license = lib.licenses.mit;
  };
}
