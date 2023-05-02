{ buildDunePackage
, dune-configurator
, eio
, lib
, iomux
, logs
, fmt
}:

buildDunePackage {
  pname = "eio_posix";
  inherit (eio) version src;

  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ eio logs fmt iomux ];
}
