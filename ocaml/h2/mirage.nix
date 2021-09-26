{ lib, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  inherit (h2) version src;
  pname = "h2-mirage";
  doCheck = false;
  propagatedBuildInputs = [
    conduit-mirage
    h2-lwt
    gluten-mirage
  ];

}
