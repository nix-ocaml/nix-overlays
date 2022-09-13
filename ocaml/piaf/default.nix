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
, sendfile
, uri
}:

buildDunePackage {
  pname = "piaf";
  version = "0.0.1-dev";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/piaf/archive/98a02d5.tar.gz;
    sha256 = "0spskc76j5vrp8l6lray7l0npg50yvhxp3p6yajm73wl56an1axk";
  };

  doCheck = false;

  propagatedBuildInputs = [
    eio
    eio_main
    eio-ssl
    httpaf-eio
    h2-eio
    ipaddr
    magic-mime
    multipart_form
    sendfile
    uri
  ];

  meta = {
    description = "An HTTP library with HTTP/2 support written entirely in OCaml";
    license = lib.licenses.bsd3;
  };
}
