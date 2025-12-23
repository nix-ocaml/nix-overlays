{
  buildDunePackage,
  httpun,
  gluten-lwt,
  lwt,
}:

buildDunePackage {
  pname = "httpun-lwt";
  inherit (httpun) version src;
  propagatedBuildInputs = [
    httpun
    gluten-lwt
    lwt
  ];
}
