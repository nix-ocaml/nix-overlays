{
  buildDunePackage,
  h2,
  h2-lwt,
  gluten-mirage,
}:

buildDunePackage {
  inherit (h2) version src;
  pname = "h2-mirage";
  doCheck = false;
  propagatedBuildInputs = [
    h2-lwt
    gluten-mirage
  ];
}
