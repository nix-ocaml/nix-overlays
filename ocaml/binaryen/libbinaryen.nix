{ lib, fetchFromGitHub, buildDunePackage, dune-configurator, js_of_ocaml, cmake }:

buildDunePackage rec {
  pname = "libbinaryen";
  version = "109.0.1";

  src = fetchFromGitHub {
    owner = "grain-lang";
    repo = "libbinaryen";
    rev = "v${version}";
    sha256 = "sha256-JqD1RNQ1+Kmv11RF6yqRUKeJvoT3bTIUud5iKlA/ogc=";
  };

  nativeBuildInputs = [ dune-configurator js_of_ocaml cmake ];

  propagatedBuildInputs = [ libbinaryen ];
}