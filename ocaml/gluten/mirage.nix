{
  buildDunePackage,
  faraday-lwt,
  gluten,
  gluten-lwt,
  mirage-flow,
  cstruct,
}:

buildDunePackage {
  pname = "gluten-mirage";
  inherit (gluten) src version;

  propagatedBuildInputs = [
    faraday-lwt
    gluten-lwt
    mirage-flow
    cstruct
  ];
}
