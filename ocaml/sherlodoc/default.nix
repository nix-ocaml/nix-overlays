{ lib
, fetchFromGitHub
, buildDunePackage
, js_of_ocaml-compiler
, result
, tyxml
, ppx_blob
, lwt
, fpath
, decompress
, cmdliner
, brr
, bigstringaf
, base64
, odoc
, odoc-parser
, menhir
, fmt
, dream
, enableServe ? false
,
}:

buildDunePackage {
  pname = "sherlodoc";
  version = "0.2";
  src = fetchFromGitHub {
    owner = "art-w";
    repo = "sherlodoc";
    rev = "0.2";
    sha256 = "sha256-MEYKtlVoSYZhh4ernon1FHGFykfeCmv6qQi+cyy3LX8=";
  };
  nativeBuildInputs = [ menhir js_of_ocaml-compiler ];
  propagatedBuildInputs = [
    result
    tyxml
    ppx_blob
    lwt
    fpath
    decompress
    cmdliner
    brr
    bigstringaf
    base64
    odoc
    odoc-parser
    fmt
  ] ++ lib.optional enableServe dream;
}
