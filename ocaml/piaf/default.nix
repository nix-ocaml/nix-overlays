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
    rev = "d3b2b3c9e40f6ba9a0ac27d2dfc49a1e5fcfb18f";
    hash = "sha256-PHUbG3HXMmf8u8HnV3KM6dHgY8RT1pj6VNdO8tHJPuI=";
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
