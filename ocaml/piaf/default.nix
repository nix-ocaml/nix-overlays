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
, pecu
, prettym
, uri
, uutf
, unstrctrd
, httpun-ws
, alcotest
, dune-site
, ocaml
}:

buildDunePackage {
  pname = "piaf";
  version = "0.2.0";
  src = builtins.fetchurl {
    url = "https://github.com/anmonteiro/piaf/releases/download/0.2.0/piaf-0.2.0.tbz";
    sha256 = "1yvhfc8g4mclmddckivvbhc9n9zm0x8ff5k1v3kambigll4r1yh7";
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
