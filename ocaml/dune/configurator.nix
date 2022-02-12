{ lib, buildDunePackage, dune, csexp }:

buildDunePackage {
  pname = "dune-configurator";
  inherit (dune) src version;

  propagatedBuildInputs = [ csexp ];
  preBuild = ''
    rm -rf vendor/csexp
    rm -rf vendor/pp
  '';
  dontAddPrefix = true;
}
