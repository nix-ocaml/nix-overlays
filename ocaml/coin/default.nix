{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "coin";

  version = "0.1.3";

  src = builtins.fetchurl {
    url = "https://github.com/mirage/coin/releases/download/v${version}/coin-v${version}.tbz";
    sha256 = "0gr5kw2npq8wpfj1g86sa8jl4lkk00i5bfj7y1drzfgpchb7hbbv";
  };

  propagatedNativeBuildInputs = [ menhir ];
  propagatedBuildInputs = [ menhir ];
}
