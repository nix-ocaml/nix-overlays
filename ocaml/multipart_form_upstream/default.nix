{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "multipart_form";

  version = "0.3.0";

  src = builtins.fetchurl {
    url = https://github.com/dinosaure/multipart_form/releases/download/v0.3.0/multipart_form-v0.3.0.tbz;
    sha256 = "05cbs2fqvyg67nmyfi8cp8bzl3yzkzw1w2az8brdkxcw1cq9xkgl";
  };

  doCheck = true;
  checkInputs = [ alcotest rosetta ];

  propagatedBuildInputs = [
    angstrom
    base64
    unstrctrd
    rresult
    uutf
    pecu
    lwt
    prettym
    fmt
    logs
    ke
    bigstringaf
  ];
}
