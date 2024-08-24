{ buildDunePackage
, httpun-ws
, httpun-ws-lwt
, gluten-mirage
}:

buildDunePackage {
  pname = "httpun-ws-mirage";
  inherit (httpun-ws) src version;

  propagatedBuildInputs = [ httpun-ws-lwt gluten-mirage ];
}
