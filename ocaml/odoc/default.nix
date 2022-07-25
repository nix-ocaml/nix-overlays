{ lib
, buildDunePackage
, odoc-parser
, camlp-streams
, astring
, cmdliner
, cppo
, fpath
, result
, tyxml
, fmt
, bisect_ppx
, ppx_expect
, ocaml-version
, lwt
, findlib
, alcotest
, markup
, yojson
, sexplib
, jq
, which
}:

buildDunePackage {
  pname = "odoc";
  version = "2.1.1";

  minimumOCamlVersion = "4.03";

  src = builtins.fetchurl {
    url = https://github.com/ocaml/odoc/releases/download/2.1.1/odoc-2.1.1.tbz;
    sha256 = "1zc7z627hlzsawhy2kxv11j1yvfzbnwlnp2jjlmkmz6hik9dnx7m";
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
    jq
    which
  ];

  # something is broken
  doCheck = false;

  meta = {
    description = "A documentation generator for OCaml";
    license = lib.licenses.isc;
  };
}
