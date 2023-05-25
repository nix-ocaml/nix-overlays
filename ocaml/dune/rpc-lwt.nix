{ lib, buildDunePackage, dune, dune-rpc, lwt, csexp, dyn, result }:


buildDunePackage {
  pname = "dune-rpc-lwt";
  inherit (dune) src version;

  propagatedBuildInputs = [ csexp dune-rpc lwt result ];
  dontAddPrefix = true;
  inherit (dyn) preBuild;
}
