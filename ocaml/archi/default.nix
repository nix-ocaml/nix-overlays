{ fetchFromGitHub, buildDunePackage, alcotest, hmap }:

buildDunePackage {
  pname = "archi";
  version = "0.1.1-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "archi";
    rev = "60f07c6";
    sha256 = "sha256-0Rvfw60PS413oqWa7ISmHmZU12CtKlf53hZlKjJ+Hgc=";
  };

  checkInputs = [ alcotest ];
  propagatedBuildInputs = [ hmap ];
}
