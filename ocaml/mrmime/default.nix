{ stdenv, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "mrmime";
  version = "0.3.2";
  src = builtins.fetchurl {
    url = https://github.com/mirage/mrmime/releases/download/v0.3.2/mrmime-v0.3.2.tbz;
    sha256 = "0c9b4s0w56s7bk646ms2s4l4b0l8c61mnj3yxw7hlnpjdvq7rqqg";
  };

  propagatedBuildInputs = [
    rresult
    fmt
    ke
    unstrctrd
    ptime
    uutf
    rosetta
    ipaddr
    emile
    base64
    pecu
    bigstringaf
    bigarray-compat
    bigarray-overlap
    angstrom
  ];

  checkInputs = [ hxd alcotest jsonm ];
}
