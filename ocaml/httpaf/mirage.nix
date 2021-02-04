{ ocamlPackages }:

with ocamlPackages;

buildDunePackage
{
  inherit (httpaf) version src;
  pname = "httpaf-mirage";
  doCheck = false;
  propagatedBuildInputs = [
    conduit-mirage
    httpaf-lwt
    gluten-mirage
  ];
}
