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
  version = "0.0.1-unvendor";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "piaf";
    rev = "a4ea85f29f41bd37d88aac2bb94a89967a8136a7";
    sha256 = "sha256-0Q6ARgCS+ub0q5n0gKaBBslrvfpz1nfSTVs2uhYKvyg=";
  };

  patches = [ ./unvendor.patch ];

  # for some reason tests fail on macOS in CI.
  doCheck = false;
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
