{
  buildDunePackage,
  inotify,
  eio,
  eio_main,
  iomux,
  ounit2,
  fileutils,
}:

buildDunePackage {
  pname = "inotify-eio";
  inherit (inotify) version src meta;
  minimalOCamlVersion = "5.0";
  propagatedBuildInputs = [
    inotify
    eio
    iomux
  ];
  checkInputs = [
    ounit2
    fileutils
    eio_main
  ];
  doCheck = true;
}
