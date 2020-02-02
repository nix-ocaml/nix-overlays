{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDunePackage rec {
  pname = "routes";
  version = "0.0.1-dev";

  src = fetchFromGitHub {
    owner = "anuragsoni";
    repo = pname;
    rev = "2145892ea74edae2e0fa02c65a52d830d81815ee";
    sha256 = "1i32hm5awcngarqi8pk3nk9dg834x72c3vqzv0r609fsyryf1qhs";
  };
}
