{ stdenv
, lib
, fetchFromGitHub
, alcotest
, alcotest-lwt
, angstrom
, base64
, buildDunePackage
, dune-site
, faraday
, gluten-lwt-unix
, h2
, h2-lwt-unix
, httpaf
, httpaf-lwt-unix
, ipaddr
, logs
, lwt_ssl
, magic-mime
, pecu
, prettym
, psq
, rresult
, ssl
, unstrctrd
, uri
}:

buildDunePackage {
  pname = "piaf";
  version = "0.0.1-dev";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "piaf";
    rev = "ed5c9d36f3cb6681babb951d58ac087f1018e79c";
    sha256 = "sha256-wBXpvoX5o1cFV/1ipDrSREvfCQNiIhRX7vMUay1hIg0=";
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
