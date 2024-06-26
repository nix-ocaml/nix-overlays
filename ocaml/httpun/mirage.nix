{
  buildDunePackage,
  conduit-mirage,
  httpun,
  httpun-lwt,
  gluten-mirage,
}:

buildDunePackage {
  inherit (httpun) version src;
  pname = "httpun-mirage";
  doCheck = false;
  propagatedBuildInputs = [
    conduit-mirage
    httpun-lwt
    gluten-mirage
  ];
}
