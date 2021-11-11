{ buildDunePackage
, httpaf
, httpaf-lwt
, gluten-lwt-unix
, faraday-lwt-unix
, lwt_ssl
}:

buildDunePackage {
  inherit (httpaf) version src;
  pname = "httpaf-lwt-unix";
  propagatedBuildInputs = [
    httpaf
    httpaf-lwt
    gluten-lwt-unix
    faraday-lwt-unix
    lwt_ssl
  ];
}
