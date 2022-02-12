{ lib, buildDunePackage, dune, stdune, dune-private-libs }:


buildDunePackage {
  pname = "dune-glob";
  inherit (dune) src version;

  propagatedBuildInputs = [ stdune dune-private-libs ];
  dontAddPrefix = true;
  preBuild = ''
    rm -rf vendor/csexp
    rm -rf vendor/pp
  '';
}
