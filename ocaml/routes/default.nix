{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDunePackage rec {
  pname = "routes";
  version = "0.8.0";

  src = builtins.fetchurl {
    url = https://github.com/anuragsoni/routes/releases/download/0.8.0/routes-0.8.0.tbz;
    sha256 = "0ikw5b4jrif0psk5kiwagyg15fwypff2b8xzhq9qr80zsq2nny7s";
  };
}
