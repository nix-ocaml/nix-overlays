{ buildDunePackage, gluten, lwt }:

buildDunePackage {
  pname = "gluten-lwt";
  propagatedBuildInputs = [ gluten lwt ];
  inherit (gluten) src version;
}
