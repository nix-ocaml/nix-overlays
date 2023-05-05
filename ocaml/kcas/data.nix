{ buildDunePackage, kcas }:

buildDunePackage {
  pname = "kcas_data";
  inherit (kcas) version src;

  propagatedBuildInputs = [ kcas ];
}
