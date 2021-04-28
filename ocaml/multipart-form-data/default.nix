{ ocamlPackages, fetchFromGitHub }:

with ocamlPackages;

buildDunePackage rec {
  pname = "multipart-form-data";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "cryptosense";
    repo = pname;
    rev = version;
    sha256 = "10j42v1r7q9ygy2gqsdl0vjl449dkirgd09q4kzqng2vyl70kinw";
  };

  propagatedBuildInputs = [
    lwt
    lwt_ppx
    stringext
  ];
}
