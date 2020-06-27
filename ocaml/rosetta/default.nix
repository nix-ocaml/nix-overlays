{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "rosetta";

  version = "0.3.0";

  src = builtins.fetchurl {
    url = "https://github.com/mirage/rosetta/releases/download/v${version}/rosetta-v${version}.tbz";
    sha256 = "0r2553gb8j3jxsrwmgnxxikmymxjid9kfl987gr06sxgg27n7yyz";
  };

  propagatedBuildInputs = [
    uuuu
    yuscii
    coin
  ];
}
