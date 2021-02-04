{ stdenv, ocamlPackages, lib, fetchFromGitHub }:

with ocamlPackages;
let src = fetchFromGitHub {
  owner = "anmonteiro";
  repo = "piaf";
  rev = "03bfe63806a7affb09f57a9ac5844fddf67446b6";
  sha256 = "13811z9v0c4s48k299qsb92mdihzinrm86zny99hxs4819hqspsn";
  fetchSubmodules = true;
};

in
ocamlPackages.buildDunePackage {
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
