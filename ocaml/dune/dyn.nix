{ lib, buildDunePackage, dune, ordering, pp }:


buildDunePackage {
  pname = "dyn";
  inherit (dune) src version;

  propagatedBuildInputs = [ ordering pp ];
  dontAddPrefix = true;
  preBuild = ''
    rm -rf vendor/csexp
    rm -rf vendor/pp
  '';
}
