{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "decimal";
  version = "0.0.3";
  src = builtins.fetchurl {
    url = "https://github.com/yawaramin/ocaml-decimal/releases/download/v${version}/decimal-v${version}.tbz";
    sha256 = "100ydshdfhr0lqglbr0y79i6h6v1s2f47w1qlcyb6m3x21lwi6nq";
  };

  propagatedBuildInputs = [ zarith ];
}
