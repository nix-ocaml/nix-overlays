{
  buildDunePackage,
  js_of_ocaml-compiler,
  js_of_ocaml,
  result,
  tyxml,
  ppx_blob,
  lwt,
  fpath,
  fmt,
  decompress,
  cmdliner,
  brr,
  bigstringaf,
  base64,
  odoc,
  odoc-parser,
  menhir,
}:

buildDunePackage {
  pname = "sherlodoc";
  inherit (odoc) version src;
  nativeBuildInputs = [
    menhir
    js_of_ocaml-compiler
  ];
  propagatedBuildInputs = [
    js_of_ocaml
    result
    tyxml
    ppx_blob
    lwt
    fpath
    fmt
    decompress
    cmdliner
    brr
    bigstringaf
    base64
    odoc
    odoc-parser
  ];
}
