{ lib, buildDunePackage, dune }:


buildDunePackage {
  pname = "ordering";
  inherit (dune) src version;
  dontAddPrefix = true;
}
