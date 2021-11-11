{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "websocketaf-mirage";
  inherit (websocketaf) src version;

  propagatedBuildInputs = [
    conduit-mirage
    websocketaf-lwt
    gluten-mirage
  ];
}
