{ lib, buildDunePackage, dune, dune-rpc, lwt, csexp }:


buildDunePackage {
  pname = "dune-rpc-lwt";
  inherit (dune) src version;

  propagatedBuildInputs = [ csexp dune-rpc lwt ];
  dontAddPrefix = true;
  preBuild = ''
    rm -rf vendor/csexp
    rm -rf vendor/pp
  '';
}
