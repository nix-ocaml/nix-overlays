{ stdenv, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDunePackage rec {
  pname = "routes";
  version = "0.9.1";

  src = builtins.fetchurl {
    url = "https://github.com/anuragsoni/routes/releases/download/${version}/routes-${version}.tbz";
    sha256 = "0h2c1p5w6237c1lmsl5c8q2dj5dq20gf2cmb12nbmlfn12sfmcrl";
  };
}
