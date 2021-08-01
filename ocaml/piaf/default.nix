{ stdenv
, lib
, fetchFromGitHub
, buildDunePackage
, alcotest
, alcotest-lwt
, dune-site
, logs
, lwt_ssl
, ssl
, uri
, ipaddr
, magic-mime
, angstrom
, faraday
, gluten-lwt-unix
, psq
, pecu
, prettym
, unstrctrd
, base64
, rresult
}:

buildDunePackage {
  pname = "piaf";
  version = "0.0.1-dev";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "piaf";
    rev = "93067d0a67b97f1d76e82eedb19cb9893c52845d";
    sha256 = "1ddq58kkgcvpz45adr1faa2pzbahf5prdc9spmd8wyh0jraxcllc";
    fetchSubmodules = true;
  };

  patches = [ ./unvendor.patch ];

  doCheck = true;
  checkInputs = [ alcotest alcotest-lwt dune-site ];

  propagatedBuildInputs = [
    logs
    lwt_ssl
    ssl
    uri
    ipaddr
    magic-mime

    # (vendored) httpaf dependencies
    angstrom
    faraday
    gluten-lwt-unix
    psq
    pecu
    prettym
    unstrctrd
    base64
    rresult

    httpaf
    httpaf-lwt-unix
    h2
    h2-lwt-unix
  ];

  meta = {
    description = "An HTTP library with HTTP/2 support written entirely in OCaml";
    license = lib.licenses.bsd3;
  };
}
