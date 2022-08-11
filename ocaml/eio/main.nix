{ buildDunePackage, eio, eio_luv }:

buildDunePackage {
  pname = "eio_main";
  inherit (eio) version src;

  propagatedBuildInputs = [ eio_luv ];
}
