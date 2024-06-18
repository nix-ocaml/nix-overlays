{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-h2";
    rev = "a922389b9832b461673ebafc6f32234383e42a21";
    hash = "sha256-qfoDoPw2iw7D/jaQ3GFuxKTuh5SnRyBHPZkDg62VZdI=";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
