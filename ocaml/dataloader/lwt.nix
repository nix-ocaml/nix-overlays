{ buildDunePackage, dataloader, lwt }:

buildDunePackage {
  pname = "dataloader-lwt";
  inherit (dataloader) version src;

  propagatedBuildInputs = [ dataloader lwt ];
}
