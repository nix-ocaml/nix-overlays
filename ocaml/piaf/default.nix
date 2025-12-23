{
  stdenv,
  lib,
  fetchFromGitHub,
  buildDunePackage,
  eio,
  eio_main,
  eio-ssl,
  h2-eio,
  httpun-eio,
  ipaddr,
  magic-mime,
  pecu,
  prettym,
  uri,
  uutf,
  unstrctrd,
  httpun-ws,
  alcotest,
  dune-site,
  ocaml,
}:

buildDunePackage {
  pname = "piaf";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "piaf";
    rev = "c27b38e4493e81b0a7c895c620976bf155f14d8b";
    hash = "sha256-3IUxX3Zax5ddMTKJufMCeRvZoFWbTYMvfHFFpN15PuA=";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [
    eio
    eio_main
    eio-ssl
    httpun-eio
    h2-eio
    ipaddr
    magic-mime
    pecu
    prettym
    unstrctrd
    uutf
    uri
    httpun-ws
  ];

  meta = {
    description = "An HTTP library with HTTP/2 support written entirely in OCaml";
    license = lib.licenses.bsd3;
  };
}
