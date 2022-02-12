{ lib, buildDunePackage, dune, stdune, dyn }:


buildDunePackage {
  pname = "fiber";
  inherit (dune) src version;

  propagatedBuildInputs = [ dyn stdune ];
  dontAddPrefix = true;
  preBuild = ''
    rm -rf vendor/csexp
    rm -rf vendor/pp
  '';
}
