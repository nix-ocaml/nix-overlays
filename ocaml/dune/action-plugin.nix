{ lib, buildDunePackage, dune, dune-glob, csexp, stdune, dune-private-libs, pp }:


buildDunePackage {
  pname = "dune-action-plugin";
  inherit (dune) src version;

  propagatedBuildInputs = [ dune-glob csexp stdune dune-private-libs pp ];
  dontAddPrefix = true;
  preBuild = ''
    rm -rf vendor/csexp
    rm -rf vendor/pp
  '';
}
