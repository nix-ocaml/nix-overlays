{ buildDunePackage
, faraday-lwt
, gluten
, gluten-lwt
, conduit-mirage
, mirage-flow
, cstruct
}:

buildDunePackage {
  pname = "gluten-mirage";
  inherit (gluten) src version;

  propagatedBuildInputs = [
    faraday-lwt
    gluten-lwt
    conduit-mirage
    mirage-flow
    cstruct
  ];
}
