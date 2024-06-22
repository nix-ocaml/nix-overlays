{ stdenv
, lib
, fetchFromGitHub
, buildDunePackage
, eio
, eio_main
, eio-ssl
, h2-eio
, httpun-eio
, ipaddr
, magic-mime
, multipart_form
, uri
, httpun-ws
, alcotest
, dune-site
, ocaml
}:

buildDunePackage {
  pname = "piaf";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "piaf";
    rev = "d3ca40ff5210e554e0f7bc9e7ff13f51d0181581";
    hash = "sha256-N5sUK9CpUYQKCiuwnSaVeg/Jj6lpn4XGEzE9YFeZJq0=";
  };

  propagatedBuildInputs = [
    eio
    eio_main
    eio-ssl
    httpun-eio
    h2-eio
    ipaddr
    magic-mime
    multipart_form
    uri
    httpun-ws
  ];

  meta = {
    description = "An HTTP library with HTTP/2 support written entirely in OCaml";
    license = lib.licenses.bsd3;
  };
}
