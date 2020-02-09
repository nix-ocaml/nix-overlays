{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "jose";
  version = "0.1.0-dev";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "reason-jose";
    rev = "4853b4d2bdf0292384ed7d7a814852d63129a3c3";
    sha256 = "1p4783y9q9xicvlvfg57yx7j4qcppr9pig3rr06ks7s0x868azy8";
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
