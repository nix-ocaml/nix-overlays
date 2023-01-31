{ fetchFromGitHub, buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "gluten";
    rev = "870eb19";
    sha256 = "sha256-9+kRImfr9iRALmVbeSfUo1HZasdASJwtvCOgqINPDxw=";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
