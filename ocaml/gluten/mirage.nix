{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "gluten-mirage";
  inherit (gluten) src version;

  propagatedBuildInputs = [
    faraday-lwt
    gluten-lwt
    conduit-mirage
    mirage-flow
    cstruct
  ];
}
