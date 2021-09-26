{ lib, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  inherit (h2) version src;
  pname = "h2-lwt";
  propagatedBuildInputs = [ gluten-lwt h2 lwt ];
}
