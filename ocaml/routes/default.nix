{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDunePackage rec {
  pname = "routes";
  version = "0.0.1-dev";

  src = fetchFromGitHub {
    owner = "anuragsoni";
    repo = pname;
    rev = "e057f498bae4604fff7edbe1c92b3c72b3fe8bc4";
    sha256 = "1qg4nwmmpj97x938wpdxzv4zx85xn5pflzk6hp5q52qm7n2dibrq";
  };
}
