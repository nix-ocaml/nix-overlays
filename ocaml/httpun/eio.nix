{ buildDunePackage
, httpun
, gluten-eio
, eio_main
}:

buildDunePackage {
  inherit (httpun) version src;
  pname = "httpun-eio";
  propagatedBuildInputs = [
    httpun
    gluten-eio
    eio_main
  ];
}
