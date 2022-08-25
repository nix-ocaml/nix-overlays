{ buildDunePackage, gluten, eio, eio_main, eio-ssl }:

buildDunePackage {
  pname = "gluten-eio";
  inherit (gluten) src version;

  propagatedBuildInputs = [ gluten eio eio_main eio-ssl ];
}
