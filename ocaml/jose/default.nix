{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "jose";
  version = "0.5.5-dev";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "reason-jose";
    rev = "9549a67ae37af28444773f93631cee2716fa1c30";
    sha256 = "18jxj85zgajq8w3likd7phiyy2x3nqidarmx7lcp2kkbs0bldz21";
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
