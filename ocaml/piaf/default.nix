{ stdenv
, lib
, buildDunePackage
, eio
, eio_main
, eio-ssl
, h2-eio
, httpaf-eio
, ipaddr
, magic-mime
, multipart_form
, uri
, websocketaf
, alcotest
, dune-site
}:

buildDunePackage {
  pname = "piaf";
  version = "n/a";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/piaf/archive/195f456.tar.gz;
    sha256 = "16f4jlfb4r0789clc0xzanqgkmzcngyqh8qjycbdmccx3nzy38p0";
  };

  doCheck = true;
  checkInputs = [ alcotest dune-site ];

  propagatedBuildInputs = [
    eio
    eio_main
    eio-ssl
    httpaf-eio
    h2-eio
    ipaddr
    magic-mime
    multipart_form
    uri
    websocketaf
  ];

  meta = {
    description = "An HTTP library with HTTP/2 support written entirely in OCaml";
    license = lib.licenses.bsd3;
  };
}
