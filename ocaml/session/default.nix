{ lib, fetchFromGitHub, buildDunePackage, mirage-crypto, mirage-crypto-rng, base64 }:

buildDunePackage {
  pname = "session";
  version = "0.5.0-dev";
  src = fetchFromGitHub {
    owner = "inhabitedtype";
    repo = "ocaml-session";
    rev = "6180413996e8c95bd78a9afa1431349a42c95588";
    sha256 = "sha256-3n3LN1lFWy/F24Gnoc7Bhp69VUEVLZFITaXLL1vMzG4=";
  };

  propagatedBuildInputs = [ mirage-crypto mirage-crypto-rng base64 ];

  meta = {
    description = "A session manager for your everyday needs";
    license = lib.licenses.bsd3;
  };
}
