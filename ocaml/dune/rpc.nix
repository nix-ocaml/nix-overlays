{ lib, buildDunePackage, dune, dyn, ordering, pp, csexp, xdg, stdune }:


buildDunePackage {
  pname = "dune-rpc";
  inherit (dune) src version;

  propagatedBuildInputs = [ dyn ordering pp csexp xdg stdune ];
  dontAddPrefix = true;
  preBuild = ''
    rm -rf vendor/csexp
    rm -rf vendor/pp
  '';

}
