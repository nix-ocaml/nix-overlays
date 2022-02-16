{ ocamlPackages, pkgs, lib }:

with ocamlPackages;

buildDunePackage {
  pname = "odoc";
  version = "2.1.0";

  minimumOCamlVersion = "4.02";

  src = builtins.fetchurl {
    url = "https://github.com/ocaml/odoc/archive/refs/tags/2.1.0.tar.gz";
    sha256 = "0g5wpsswidajifj3mabbdbyrcihid56mdgl9m3zyn4cap9rpfc3b";
  };

  useDune2 = true;

  propagatedBuildInputs = [
    odoc-parser
    astring
    cmdliner
    cppo
    fpath
    result
    tyxml
    fmt
  ];

  checkInputs = [
    bisect_ppx
    ppx_expect
    ocaml-version
    lwt
    findlib
    alcotest
    markup
    yojson
    sexplib
    pkgs.jq
    pkgs.which
  ];

  # something is broken
  # doCheck = true;

  meta = {
    description = "A documentation generator for OCaml";
    license = lib.licenses.isc;
  };
}
