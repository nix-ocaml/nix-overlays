{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "landmarks";
  version = "1.3";
  src = builtins.fetchurl {
    url = https://github.com/LexiFi/landmarks/archive/b865bd1.tar.gz;
    sha256 = "13h4ll463gdz4fa94d357sf0g0xv07wa022x0zbzrgi25ax12274";
  };

  propagatedBuildInputs = [ ppxlib ];
}
