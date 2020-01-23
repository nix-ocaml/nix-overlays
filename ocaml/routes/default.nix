{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDunePackage rec {
  pname = "routes";
  version = "0.0.1-dev";

  src = fetchFromGitHub {
    owner = "anuragsoni";
    repo = pname;
    rev = "19dfad6783c2135d89466606af3e0855dbd79113";
    sha256 = "1anzlnvsa3na4wq895flr1x76ws78k1b7qwsjy8smj9ckn3bm4zv";
  };
}
