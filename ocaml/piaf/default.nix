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
    url = https://github.com/anmonteiro/piaf/archive/58be914.tar.gz;
    sha256 = "0rrwsp1xlq6z1gfywd90mz7lqrgkdhzxmihdkwv1cihb94vsr541";
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
