{ ocamlPackages, lib }:

with ocamlPackages;

buildDunePackage {
  pname = "ppx_deriving_bson";
  inherit (bson) src version;

  propagatedBuildInputs = [ ppxlib ppx_deriving bson ];
}
