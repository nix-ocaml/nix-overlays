{ ocamlPackages, pkgs, lib }:

with ocamlPackages;

buildDunePackage {
  pname = "odoc";
  version = "2.0.0-beta2";

  minimumOCamlVersion = "4.02";

  src = builtins.fetchurl {
    url = "https://github.com/ocaml/odoc/archive/refs/tags/2.0.0-beta3.tar.gz";
    sha256 = "00qpaslyag6f3f64sj2wnq0qyc40ajhla8pcg4x0gn6f6rlrgyxs";
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
