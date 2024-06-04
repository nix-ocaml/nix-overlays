{ buildDunePackage, httpun-ws, gluten-lwt, lwt, digestif }:

buildDunePackage {
  pname = "httpun-ws-lwt";
  inherit (httpun-ws) src version;
  propagatedBuildInputs = [ httpun-ws gluten-lwt lwt digestif ];
}
