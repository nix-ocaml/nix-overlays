{ lib, buildDunePackage, dune, dune-private-libs }:


buildDunePackage {
  pname = "dune-site";
  inherit (dune) src version;

  propagatedBuildInputs = [ dune-private-libs ];
  dontAddPrefix = true;
  preBuild = ''
    rm -rf vendor/csexp
    rm -rf vendor/pp
  '';
}
