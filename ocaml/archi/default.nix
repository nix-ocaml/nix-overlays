{ fetchFromGitHub, buildDunePackage, alcotest, hmap }:

buildDunePackage {
  pname = "archi";
  version = "0.1.1-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "archi";
    rev = "d60925750d55166c799cb2685e9ed1d1382a2d6a";
    hash = "sha256-Ce+RXI3bo68031zqD/G5NKYg9feVXWwqmto6xZb6rwM=";
  };

  checkInputs = [ alcotest ];
  propagatedBuildInputs = [ hmap ];
}
