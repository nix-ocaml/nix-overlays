{
  buildDunePackage,
  conduit-mirage,
  httpun-ws,
  httpun-ws-lwt,
  gluten-mirage,
}:

buildDunePackage {
  pname = "httpun-ws-mirage";
  inherit (httpun-ws) src version;

  propagatedBuildInputs = [
    conduit-mirage
    httpun-ws-lwt
    gluten-mirage
  ];
}
