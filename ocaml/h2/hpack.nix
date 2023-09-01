{ fetchFromGitHub, buildDunePackage, angstrom, faraday }:

buildDunePackage {
  pname = "hpack";
  version = "0.10.0-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-h2";
    rev = "f92e6889aec5edfae0234ffd204142b5095af07d";
    hash = "sha256-qcod6R5zQwQssAZTO2XhHiePvsYbLE/Zt7Gx7DTheDc=";
  };
  propagatedBuildInputs = [ angstrom faraday ];
}
