{ fetchFromGitHub, buildDunePackage, base, ppx_deriving, ppx_gen_rec, sedlex, wtf8 }:

buildDunePackage {
  pname = "flow_parser";
  version = "0.186.0";
  src = fetchFromGitHub {
    owner = "facebook";
    repo = "flow";
    rev = "v0.219.3";
    hash = "sha256-cL76XrfncxcoM14Hy1AFfgjaA1fGtaD58XFUPlb7EZI=";
  };

  propagatedBuildInputs = [
    base
    ppx_deriving
    ppx_gen_rec
    sedlex
    wtf8
  ];
}
