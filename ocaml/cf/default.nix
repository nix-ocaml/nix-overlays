{
  lib,
  buildDunePackage,
  fetchurl,
  ctypes,
  ctypes-foreign,
}:

buildDunePackage {
  pname = "cf";
  version = "0.5.0";
  src = fetchurl {
    url = "https://github.com/mirage/ocaml-cf/releases/download/0.5.0/cf-lwt-0.5.0.tbz";
    hash = "sha256-0weDJTikkwI748es616VlOUJ1J4W8ekN/x3CLvRrlWQ=";
  };
  propagatedBuildInputs = [
    ctypes
    ctypes-foreign
  ];
  meta = {
    description = "OCaml bindings to macOS CoreFoundation";
    homepage = "https://github.com/mirage/ocaml-cf";
    license = lib.licenses.isc;
    platforms = lib.platforms.darwin;
  };
}
