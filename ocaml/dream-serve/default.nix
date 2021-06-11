{ lib, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "dream-serve";
  version = "1.0.0";

  src = builtins.fetchurl {
    url = "https://github.com/aantron/dream-serve/archive/refs/tags/1.0.0.tar.gz";
    sha256 = "0sqmy3jjy00laxh1skq69i7mn2lg14sa2ilap8yvjpz2bhgc7cvp";
  };

  propagatedBuildInputs = [ dream lambdasoup luv lwt lwt_ppx ];

  meta = {
    description = "Static site server with live reload";
    license = lib.licenses.mit;
  };
}
