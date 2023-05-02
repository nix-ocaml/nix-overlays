{ buildDunePackage
, darwin
, dune-configurator
, eio
, lib
, stdenv
, iomux
, logs
, fmt
}:

buildDunePackage {
  pname = "eio_posix";
  inherit (eio) version src;

  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ eio logs fmt iomux ] ++
    lib.optionals
      (darwin.apple_sdk ? Libsystem
        && !(lib.versionAtLeast "11.0.0" darwin.apple_sdk.Libsystem.version))
      [ darwin.apple_sdk_11_0.Libsystem ];
}
