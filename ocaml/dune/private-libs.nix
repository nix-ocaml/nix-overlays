{ lib, buildDunePackage, dune, dyn, pp, csexp, stdune }:


buildDunePackage {
  pname = "dune-private-libs";
  inherit (dune) src version;

  propagatedBuildInputs = [ dune csexp pp dyn stdune ];
  dontAddPrefix = true;
  preBuild = ''
    rm -rf vendor/csexp
    rm -rf vendor/pp
  '';

}
