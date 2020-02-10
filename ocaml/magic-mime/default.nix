{ ocamlPackages }:

with ocamlPackages;

buildDune2Package (rec {
  pname = "magic-mime";
  version = "1.1.2";

  src = builtins.fetchurl {
    url = "https://github.com/mirage/ocaml-magic-mime/releases/download/v${version}/magic-mime-v${version}.tbz";
    sha256 = "1sq4rfd9m3693cnzlbds4qh1xpvrv1iz1s1f75nvacbmfjy0nn8c";
  };
})
