{ buildDunePackage, httpaf, gluten-lwt, lwt }:

buildDunePackage {
  pname = "httpaf-lwt";
  inherit (httpaf) version src;
  propagatedBuildInputs = [ httpaf gluten-lwt lwt ];
}
