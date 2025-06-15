{ fetchFromGitHub, buildDunePackage, base, ppx_deriving, ppx_gen_rec, sedlex, wtf8 }:

buildDunePackage {
  pname = "flow_parser";
  version = "0.273.1";
  src = fetchFromGitHub {
    owner = "facebook";
    repo = "flow";
    rev = "v0.273.1";
    hash = "sha256-rXFckFY/QtDls1jYrwDDbJE5lpIttBTzs70+U6igAZo=";
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
