{
  fetchFromGitHub,
  buildDunePackage,
  ocaml,
  base,
  ppx_deriving,
  ppx_gen_rec,
  sedlex,
  wtf8,
  lib,
}:

buildDunePackage {
  pname = "flow_parser";
  version = "0.320.0";
  src = fetchFromGitHub {
    owner = "facebook";
    repo = "flow";
    rev = "v0.320.0";
    hash = "sha256-omofSh2P2IyyEVF6I4nf/5/45K58IEsbTSo1O1mIL64=";
  };

  postPatch =
    (
      if (lib.versionAtLeast ocaml.version "4.14" && !(lib.versionAtLeast ocaml.version "5.0")) then
        ''
          substituteInPlace "src/parser/parser_common.ml" --replace-fail \
          'List.is_empty arguments' 'arguments = []'
        ''
      else
        ""
    )
    + ''
      substituteInPlace "src/parser/dune" \
        --replace-fail \
          'public_name flow_parser)' \
          'public_name flow_parser) (flags :standard -warn-error -53)' \
        --replace-fail \
          'ppx_gen_rec ppx_deriving.std flow_sedlexing_ppx' \
          'ppx_gen_rec ppx_deriving.std sedlex.ppx'
      substituteInPlace "src/third-party/sedlex-ppx/dune" \
        --replace-fail \
          ' (package flow_parser)' \
          ""
    '';

  propagatedBuildInputs = [
    base
    ppx_deriving
    ppx_gen_rec
    sedlex
    wtf8
  ];
}
