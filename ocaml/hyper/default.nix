{ fetchFromGitHub, buildDunePackage, dream-httpaf, dream-pure, mirage-crypto-rng, uri }:

buildDunePackage rec {
  pname = "hyper";
  version = "1.0.0-alpha1";

  src = fetchFromGitHub {
    owner = "aantron";
    repo = "hyper";
    rev = "1.0.0-alpha1";
    sha256 = "sha256-pMalTnRtB1b1pKiNVpytRobNZ79YGzZYRCb64qY0fg4=";
  };

  patches = [
    ./0001-Unvendor-and-add-nix.patch
  ];

  buildInputs = [ dream-httpaf dream-pure mirage-crypto-rng uri ];
}
