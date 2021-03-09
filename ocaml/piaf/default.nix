{ stdenv, ocamlPackages, lib, fetchFromGitHub }:

with ocamlPackages;
let src = fetchFromGitHub {
  owner = "anmonteiro";
  repo = "piaf";
  rev = "0.1.0";
  sha256 = "190qa43h13i6i2ygb694g8929i036137xvxcc34xs6rmrx4xbbgn";
  fetchSubmodules = true;
};

in
buildDunePackage {
  pname = "piaf";
  version = "0.0.1-dev";
  inherit src;

  doCheck = true;
  checkInputs = [ alcotest alcotest-lwt ];

  propagatedBuildInputs = [
    logs
    lwt_ssl
    magic-mime
    ssl
    uri

    # (vendored) httpaf dependencies
    angstrom
    faraday
    gluten-lwt-unix
    psq
    pecu
    mrmime
  ];

  meta = {
    description = "An HTTP library with HTTP/2 support written entirely in OCaml";
    license = lib.licenses.bsd3;
  };
}
