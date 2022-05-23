{ buildDunePackage, typedppxlib }:

buildDunePackage {
  pname = "ppx_debug";
  inherit (typedppxlib) version src;
  propagatedBuildInputs = [ typedppxlib ];
}
