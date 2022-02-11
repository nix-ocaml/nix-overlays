{ lib, buildDunePackage, dune, dyn, ordering, pp, csexp }:


buildDunePackage {
  pname = "stdune";
  inherit (dune) src version;

  propagatedBuildInputs = [ dyn ordering pp csexp ];
  dontAddPrefix = true;
  preBuild = ''
    rm -rf vendor/csexp
    rm -rf vendor/pp
  '';
}
