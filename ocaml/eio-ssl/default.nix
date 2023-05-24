{ fetchFromGitHub, buildDunePackage, ssl, eio }:

buildDunePackage {
  pname = "eio-ssl";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "eio-ssl";
    rev = "d638029f034e6161a4dcbf2fa62cf894607d21a4";
    hash = "sha256-ebo0uP0Dn/zPqHTrDRdYH23Xrny37XNeN0NCG9O5L/c=";
  };
  propagatedBuildInputs = [ ssl eio ];
}
