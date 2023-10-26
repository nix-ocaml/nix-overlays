{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-h2";
    rev = "c694398c1b429db622638e94f9a6f8fbce2a208a";
    hash = "sha256-MJtzongD3EhHNueVK+DtyyAn6vyF28NBB/0mcXOQRao=";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
