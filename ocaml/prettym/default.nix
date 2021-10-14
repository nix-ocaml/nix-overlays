{ stdenv, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "prettym";
  version = "0.0.2";
  src = builtins.fetchurl {
    url = "https://github.com/dinosaure/prettym/releases/download/${version}/prettym-${version}.tbz";
    sha256 = "1df5zccnmqc30rla53wbvk9j24jdlmwbfj9zhzcla11vv2fh6aq8";
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
