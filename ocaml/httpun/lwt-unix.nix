{ buildDunePackage
, httpun
, httpun-lwt
, gluten-lwt-unix
, faraday-lwt-unix
, lwt_ssl
}:

buildDunePackage {
  inherit (httpun) version src;
  pname = "httpun-lwt-unix";
  propagatedBuildInputs = [
    httpun
    httpun-lwt
    gluten-lwt-unix
    faraday-lwt-unix
    lwt_ssl
  ];
}
