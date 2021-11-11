{ buildDunePackage
, websocketaf
, websocketaf-lwt
, faraday-lwt-unix
, gluten-lwt-unix
}:

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
