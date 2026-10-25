{
  buildDunePackage,
  fetchFromGitHub,
  base64,
  digestif,
  eqaf,
  mirage-crypto,
  mirage-crypto-pk,
  mirage-crypto-ec,
  x509,
  astring,
  yojson,
  zarith,
  ptime,
}:

buildDunePackage {
  pname = "jose";
  version = "0.11.0";
  src = fetchFromGitHub {
    owner = "ulrikstrid";
    repo = "ocaml-jose";
    rev = "0.11.0";
    hash = "sha256-uLgF+fVrqMA/8g/Lusf7Js/OS6hQL9fBnyoU1j8RJxE=";
  };

  propagatedBuildInputs = [
    base64
    digestif
    eqaf
    mirage-crypto
    mirage-crypto-pk
    mirage-crypto-ec
    x509
    astring
    yojson
    zarith
    ptime
  ];
}
