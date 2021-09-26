{ stdenv, ocamlPackages, lib, fetchFromGitHub }:

with ocamlPackages;
let src = fetchFromGitHub {
  owner = "anmonteiro";
  repo = "piaf";
  rev = "4cd3eef";
  sha256 = "01ifmpaznsranh7ayir3z7910fbxl99jhg14fpdzn6a3448b40rj";
  fetchSubmodules = true;
};

in
buildDunePackage {
  pname = "piaf";
  version = "0.0.1-dev";
  inherit src;

  doCheck = true;
  checkInputs = [ alcotest alcotest-lwt dune-site ];

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
