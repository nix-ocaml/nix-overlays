{ stdenv, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "bisect_ppx";
  version = "2.6.1";

  src = builtins.fetchurl {
    url = "https://github.com/aantron/bisect_ppx/archive/2.6.1.tar.gz";
    sha256 = "17x0cs5wdj7n135pragbj737mi7yz9br3b3xskf90gizp6iksn99";
  };

  propagatedBuildInputs = [ cmdliner ppxlib ];
}
