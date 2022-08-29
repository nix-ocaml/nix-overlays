{ stdenv, lib, buildDunePackage, eio, eio_luv, eio_linux }:

buildDunePackage {
  pname = "eio_main";
  inherit (eio) version src;

  propagatedBuildInputs = [ eio_luv ] ++ lib.optional stdenv.isLinux eio_linux;
}
