{ buildDunePackage
, h2
, gluten-eio
, eio_main
}:

buildDunePackage {
  inherit (h2) version src;
  pname = "h2-eio";
  propagatedBuildInputs = [
    h2
    gluten-eio
    eio_main
  ];
}
