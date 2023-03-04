{ fetchFromGitHub
, buildDunePackage
, dream-httpaf
, dream-pure
, mirage-crypto-rng-lwt
, uri
}:

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

  propagatedBuildInputs = [
    dream-httpaf
    dream-pure
    uri
    mirage-crypto-rng-lwt
  ];

  postPatch = ''
    substituteInPlace src/http/dune --replace \
      "mirage-crypto-rng.lwt" \
      "mirage-crypto-rng-lwt"

    substituteInPlace src/http/websocket.ml --replace \
      "Mirage_crypto_rng_lwt.initialize" \
      '(fun () -> Mirage_crypto_rng_lwt.initialize (module Mirage_crypto_rng.Fortuna))'
  '';

}
