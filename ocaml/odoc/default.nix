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
  version = "2.1.0";

  minimumOCamlVersion = "4.03";

  src = builtins.fetchurl {
    url = "https://github.com/ocaml/odoc/archive/4daddaa4bc97d553c9183362872149c7d7c12d0f.tar.gz";
    sha256 = "0a664ka5ddzzhf69myd4hbb4pyhsb7h5pjkyha7vgm9v1haixrvz";
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
