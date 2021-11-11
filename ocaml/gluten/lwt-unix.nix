{ buildDunePackage, gluten, faraday-lwt-unix, gluten-lwt, lwt_ssl }:

buildDunePackage {
  pname = "gluten-lwt-unix";
  inherit (gluten) src version;

  propagatedBuildInputs = [
    faraday-lwt-unix
    gluten-lwt
    lwt_ssl
  ];
}
