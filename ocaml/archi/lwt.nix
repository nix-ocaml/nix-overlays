{ buildDunePackage, archi, lwt }:

buildDunePackage {
  pname = "archi-lwt";
  inherit (archi) version src;
  propagatedBuildInputs = [ archi lwt ];
}
