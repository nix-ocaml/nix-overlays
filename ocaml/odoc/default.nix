{ ocamlPackages, pkgs, lib }:

with ocamlPackages;

buildDunePackage {
  pname = "odoc";
  version = "2.0.0-beta2";

  minimumOCamlVersion = "4.02";

  src = builtins.fetchurl {
    url = "https://github.com/ocaml/odoc/archive/refs/tags/2.0.0-beta2.tar.gz";
    sha256 = "1jh1qny8mi4x283i3aa5zlq86y44yiwd5w8qwz28hj3bwc849zly";
  };

  useDune2 = true;

  propagatedBuildInputs = [
    astring
    cmdliner
    cppo
    fpath
    result
    tyxml
    fmt
    logs
    re
    ocaml-migrate-parsetree-2-1
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
