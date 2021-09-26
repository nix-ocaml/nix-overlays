{ lib, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  inherit (h2) version src;
  pname = "h2-lwt-unix";
  propagatedBuildInputs = [
    gluten-lwt-unix
    h2-lwt
    faraday-lwt-unix
    lwt_ssl
  ];
}
