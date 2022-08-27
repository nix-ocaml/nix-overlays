{ buildDunePackage
, httpaf
, gluten-eio
, eio_main
}:

buildDunePackage {
  inherit (httpaf) version src;
  pname = "httpaf-eio";
  propagatedBuildInputs = [
    httpaf
    gluten-eio
    eio_main
  ];
}
