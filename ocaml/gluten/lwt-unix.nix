{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "gluten-lwt-unix";
  inherit (gluten) src version;

  propagatedBuildInputs = [
    faraday-lwt-unix
    gluten-lwt
    lwt_ssl
  ];
}
