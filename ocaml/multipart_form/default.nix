{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "multipart_form";

  version = "0.0.1-dev";

  src = builtins.fetchurl {
    url = https://github.com/dinosaure/multipart_form/archive/c53bc1ddad2784d3069bf82aaa4370d762a1a870.tar.gz;
    sha256 = "0xwl0rr5vigvsm40pc0ilx7av329b8xqw34srbpj2y6g1spjgs65";
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
