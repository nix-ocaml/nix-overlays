{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-h2";
    rev = "c736ca59";
    sha256 = "sha256-5jwtoeDiQkUfZaxSRgFUaw4s+MeUGyivi3x7ELh3+1k=";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
