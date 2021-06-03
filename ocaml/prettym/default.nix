{ stdenv, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "prettym";
  version = "0.0.1";
  src = builtins.fetchurl {
    url = https://github.com/dinosaure/prettym/releases/download/0.0.1/prettym-0.0.1.tbz;
    sha256 = "4920decb20187df0a1f651e8d5abf456b341633adf3e7b23aa01adf28f6e95b4";
  };

  propagatedBuildInputs = [
    bigarray-overlap
    fmt
    ke
    bigstringaf
    ptime
  ];

  checkInputs = [
    ptime
    alcotest
    jsonm
    base64
  ];

  doCheck = true;
}
