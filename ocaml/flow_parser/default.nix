{ fetchFromGitHub, buildDunePackage, base, ppx_deriving, ppx_gen_rec, sedlex, wtf8 }:

buildDunePackage {
  pname = "flow_parser";
  version = "0.246.0";
  src = fetchFromGitHub {
    owner = "facebook";
    repo = "flow";
    rev = "v0.246.0";
    hash = "sha256-WLDEtMc8mLmf1cd39iAdFqJAh5X5lKoHEtDoMK/X8rY=";
  };

  postPatch = ''
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
