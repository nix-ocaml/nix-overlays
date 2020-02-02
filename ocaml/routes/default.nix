{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDunePackage rec {
  pname = "routes";
  version = "0.0.1-dev";

  src = fetchFromGitHub {
    owner = "anuragsoni";
    repo = pname;
    rev = "58c6a136299e9919004cb481ee2130d8c069ea82";
    sha256 = "0rqbyb9bgjd64sqq8q4mz43pjnmp0sv3xr3fxcjrclbv2lv6zs4p";
  };
}
