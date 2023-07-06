{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-h2";
    rev = "30522663369357ac3d20cfb9cb28995aa0023dd1";
    hash = "sha256-gvqAULVNLApiwKxHWtWJU6YSU7uWjdCXfc/DSsd5bcY=";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
