{ fetchFromGitHub, buildDunePackage, bigstringaf, faraday }:

buildDunePackage {
  pname = "gluten";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "gluten";
    rev = "c4e50854b1a535776d85d27fdedb632852ba6519";
    hash = "sha256-MWUEOE4QKSuWPBC7adtdCRfzWvgswwYVa/ZcAy2c1z8=";
  };
  propagatedBuildInputs = [ bigstringaf faraday ];
}
