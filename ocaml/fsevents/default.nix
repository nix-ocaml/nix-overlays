{
  lib,
  buildDunePackage,
  fetchurl,
  cf,
  ctypes,
  ctypes-foreign,
}:

buildDunePackage {
  pname = "fsevents";
  version = "0.3.0";
  src = fetchurl {
    url = "https://github.com/mirage/ocaml-fsevents/releases/download/0.3.0/fsevents-lwt-0.3.0.tbz";
    hash = "sha256-C7/qk8FOmcHbsr+d4u+Mk+TxBDSQ33PAD5wKlp9HK3o=";
  };
  propagatedBuildInputs = [
    cf
    ctypes
    ctypes-foreign
  ];
  meta = {
    description = "OCaml bindings to macOS FSEvents";
    homepage = "https://github.com/mirage/ocaml-fsevents";
    license = lib.licenses.isc;
    platforms = lib.platforms.darwin;
  };
}
