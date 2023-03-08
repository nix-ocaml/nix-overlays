{ stdenv, lib, buildDunePackage, eio, eio_posix, eio_linux }:

buildDunePackage {
  pname = "eio_main";
  inherit (eio) version src;

  propagatedBuildInputs = [ eio_posix ] ++ lib.optional stdenv.isLinux eio_linux;
}
