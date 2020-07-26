{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "ocplib-endian";
  version = "1.1";
  src = builtins.fetchurl {
    url = https://github.com/OCamlPro/ocplib-endian/archive/1.1.tar.gz;
    sha256 = "0qy5q7p11gxi5anhvi8jj6mr80ml0ih8lax5k579rsr2hsp3sns5";
  };

  buildInputs = [ cppo ];
}
