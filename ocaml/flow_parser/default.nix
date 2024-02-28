{ fetchFromGitHub, buildDunePackage, base, ppx_deriving, ppx_gen_rec, sedlex, wtf8 }:

buildDunePackage {
  pname = "flow_parser";
  version = "0.229.0";
  src = fetchFromGitHub {
    owner = "facebook";
    repo = "flow";
    rev = "v0.229.0";
    hash = "sha256-V2U53zby0XfAlKqfqUE7f6zvuwWFU2CCOy34KguZqLc=";
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
