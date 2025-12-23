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
  version = "0.273.1";
  src = fetchFromGitHub {
    owner = "facebook";
    repo = "flow";
    rev = "v0.273.1";
    hash = "sha256-rXFckFY/QtDls1jYrwDDbJE5lpIttBTzs70+U6igAZo=";
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
          'public_name flow_parser) (flags :standard -warn-error -53)'
    '';

  propagatedBuildInputs = [
    base
    ppx_deriving
    ppx_gen_rec
    sedlex
    wtf8
  ];
}
