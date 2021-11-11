{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "dataloader-lwt";
  inherit (dataloader) version src;

  propagatedBuildInputs = [ dataloader lwt ];
}
