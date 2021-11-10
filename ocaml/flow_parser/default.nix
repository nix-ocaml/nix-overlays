{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "flow_parser";
  version = "0.149.0";
  src = builtins.fetchurl {
    url = https://github.com/facebook/flow/archive/refs/tags/v0.149.0.tar.gz;
    sha256 = "1cm3r4n2iscwvs593vr3vfxsqg81ask9nh3043lcq97999cxg3xq";
  };

  patches = [ ./flow_parser_public_library.patch ];
  propagatedBuildInputs = [
    ppx_deriving
    ppx_gen_rec
    sedlex_2
    wtf8
  ];
}
