{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "flow_parser";
  version = "0.148.0";
  src = builtins.fetchurl {
    # https://github.com/facebook/flow/pull/8640
    url = https://github.com/facebook/flow/archive/73942e8.tar.gz;
    sha256 = "04d0lzii1slfk9zlb1p1r74izwlpl9bsy0gwc7vrzp6r9mdc1ndd";
  };

  patches = [ ./flow_parser_public_library.patch ];
  propagatedBuildInputs = [
    ppx_deriving
    ppx_gen_rec
    sedlex_3
    wtf8
  ];
}
