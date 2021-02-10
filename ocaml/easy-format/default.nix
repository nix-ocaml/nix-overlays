{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "easy-format";
  version = "1.3.2";
  src = builtins.fetchurl {
    url = "https://github.com/ocaml-community/easy-format/releases/download/${version}/easy-format-${version}.tbz";
    sha256 = "09hrikx310pac2sb6jzaa7k6fmiznnmhdsqij1gawdymhawc4h1l";
  };
}
