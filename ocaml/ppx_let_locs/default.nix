{ stdenv, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "ppx_let_locs";
  version = "0.0.1-dev";

  src = builtins.fetchurl {
    url = "https://github.com/EduardoRFS/ppx_let_locs/archive/6278a439b95106d70470700e960f0793e4963959.tar.gz";
    sha256 = "096dvyb087cnlrffk8jn0h6njbkv97h22qy8j13j9a4djqjs9ik4";
  };

  propagatedBuildInputs = [ reason ppxlib ppx_optcomp ];
}
