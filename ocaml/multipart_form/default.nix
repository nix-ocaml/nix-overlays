{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "multipart_form";

  version = "0.0.1-dev";

  src = fetchFromGitHub {
    owner = "dinosaure";
    repo = "multipart_form";
    rev = "c53bc1ddad2784d3069bf82aaa4370d762a1a870";
    sha256 = "1y5rsbcjj0732qh4y1s6yn6bn0kwc7kiqnsxcljyhlmvd3241rq4";
  };

  propagatedBuildInputs = [
    astring
    base64
    pecu
    rosetta
    rresult
    uutf
    fmt
    angstrom
  ];
}
