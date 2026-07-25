{
  stdenv,
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  pkg-config,
  openssl-oc,
  eio,
  eio_main,
  eio-ssl,
  h2-eio,
  httpun-eio,
  ipaddr,
  logs,
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
let
  hasEio14 = lib.versionAtLeast ocaml.version "5.2";
in
buildDunePackage {
  pname = "piaf";
  version = "n/a";
  src =
    if hasEio14 then
      fetchFromGitHub {
        owner = "anmonteiro";
        repo = "piaf";
        rev = "b8f5e94deea6e653025c37131bbf6833dc4c4c85";
        hash = "sha256-XnyJXkp0WCUsZO67rUNMjEdhZZgAJAUOfxha7V2OvuI=";
        fetchSubmodules = true;
      }
    else
      fetchFromGitHub {
        owner = "anmonteiro";
        repo = "piaf";
        rev = "c27b38e4493e81b0a7c895c620976bf155f14d8b";
        hash = "sha256-3IUxX3Zax5ddMTKJufMCeRvZoFWbTYMvfHFFpN15PuA=";
        fetchSubmodules = true;
      };

  nativeBuildInputs = lib.optionals hasEio14 [ pkg-config ];
  buildInputs = lib.optionals hasEio14 [
    dune-configurator
    openssl-oc
  ];

  propagatedBuildInputs = [
    eio
    eio_main
    eio-ssl
    httpun-eio
    h2-eio
    ipaddr
    logs
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
