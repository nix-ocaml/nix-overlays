{ buildDunePackage, ppxlib, ppx_deriving, bson }:

buildDunePackage {
  pname = "ppx_deriving_bson";
  inherit (bson) src version;

  propagatedBuildInputs = [ ppxlib ppx_deriving bson ];
}
