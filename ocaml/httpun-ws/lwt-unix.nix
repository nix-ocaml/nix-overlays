{ buildDunePackage
, httpun-ws
, httpun-ws-lwt
, faraday-lwt-unix
, gluten-lwt-unix
}:

buildDunePackage {
  pname = "httpun-ws-lwt-unix";
  inherit (httpun-ws) src version;

  propagatedBuildInputs = [
    httpun-ws
    httpun-ws-lwt
    faraday-lwt-unix
    gluten-lwt-unix
  ];
}
