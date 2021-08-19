{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "landmarks-ppx";
  inherit (landmarks) version src;
  propagatedBuildInputs = [ ppxlib landmarks ];
}
