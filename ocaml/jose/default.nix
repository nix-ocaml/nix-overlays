{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "jose";
  version = "0.5.5-dev";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "reason-jose";
    rev = "09ec905a9cfd28e33e00ccaec1102b53198e033d";
    sha256 = "0m5s1yv03vpf3r9182nam69sc9sdsppaww9ghgq500fi9bfp8knb";
  };

  propagatedBuildInputs = [
    base64
    nocrypto
    x509
    cstruct
    astring
    yojson
    zarith
  ];
}
