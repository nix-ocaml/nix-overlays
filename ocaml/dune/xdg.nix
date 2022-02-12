{ lib, buildDunePackage, dune }:


buildDunePackage {
  pname = "xdg";
  inherit (dune) src version;
  dontAddPrefix = true;
}
