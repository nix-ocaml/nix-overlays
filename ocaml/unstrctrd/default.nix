{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "unstrctrd";
  version = "0.3";
  src = builtins.fetchurl {
    url = "https://github.com/dinosaure/unstrctrd/releases/download/v${version}/unstrctrd-v${version}.tbz";
    sha256 = "0nzdinks5j5drk3ihj0p9vv9wc7zdw9rz3y886360xxrlvlv2mbk";
  };

  propagatedBuildInputs = [
    angstrom
    uutf
  ];
}
