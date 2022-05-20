{ fetchFromGitHub, buildDunePackage, dream-httpaf, dream-pure, mirage-crypto-rng, uri }:

buildDunePackage rec {
  pname = "hyper";
  version = "1.0.0-alpha1";

  src = fetchFromGitHub {
    owner = "aantron";
    repo = "hyper";
    rev = "588919c57d00ce06ff04865f57dbf9a3e6c3b801";
    sha256 = "sha256-NLlLt5g30o0bKDnJHHZ0RINhQrgcwBqUAtn3t+Q9b5A=";
  };

  patches = [
    ./0001-Unvendor-and-add-nix.patch
  ];

  buildInputs = [ dream-httpaf dream-pure mirage-crypto-rng uri ];
}
