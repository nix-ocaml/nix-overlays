{ buildDunePackage
, conduit-mirage
, websocketaf
, websocketaf-lwt
, gluten-mirage
}:

buildDunePackage {
  pname = "websocketaf-mirage";
  inherit (websocketaf) src version;

  propagatedBuildInputs = [ conduit-mirage websocketaf-lwt gluten-mirage ];
}
