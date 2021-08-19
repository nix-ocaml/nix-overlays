{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "landmarks";
  version = "1.4";
  src = builtins.fetchurl {
    url = "https://github.com/LexiFi/landmarks/archive/v${version}.tar.gz";
    sha256 = "0gcg1zc2x1xqi8p2gx8nr3nmas1c96xnbcwr92zi08lwsxmyqjdm";
  };

  propagatedBuildInputs = [ ppxlib ];
}
