{ buildDunePackage, eio, logs, uring, fmt }:

buildDunePackage {
  pname = "eio_linux";
  inherit (eio) version src;

  propagatedBuildInputs = [ eio logs uring fmt ];
}
