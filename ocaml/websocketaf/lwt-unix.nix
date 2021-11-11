{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "websocketaf-lwt-unix";
  inherit (websocketaf) src version;

  propagatedBuildInputs = [
    websocketaf
    websocketaf-lwt
    faraday-lwt-unix
    gluten-lwt-unix
  ];
}
