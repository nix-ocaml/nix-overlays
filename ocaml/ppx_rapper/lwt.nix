{ buildDunePackage, ppx_rapper, lwt, caqti-lwt }:

buildDunePackage {
  pname = "ppx_rapper_lwt";
  inherit (ppx_rapper) src version;

  propagatedBuildInputs = [ ppx_rapper lwt caqti-lwt ];
}
