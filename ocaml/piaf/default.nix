{
  stdenv,
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
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

buildDunePackage {
  pname = "piaf";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "piaf";
    rev = "b8f5e94deea6e653025c37131bbf6833dc4c4c85";
    hash = "sha256-XnyJXkp0WCUsZO67rUNMjEdhZZgAJAUOfxha7V2OvuI=";
    fetchSubmodules = true;
  };

  buildInputs = [ dune-configurator ];

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
