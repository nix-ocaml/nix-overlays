{ buildDunePackage, websocketaf, gluten-lwt, lwt, digestif }:

buildDunePackage {
  pname = "websocketaf-lwt";
  inherit (websocketaf) src version;
  propagatedBuildInputs = [ websocketaf gluten-lwt lwt digestif ];
}
