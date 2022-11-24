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
, websocketaf
}:

buildDunePackage {
  pname = "piaf";
  version = "n/a";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/piaf/archive/8c2329e.tar.gz;
    sha256 = "0ymavp7ij488n25q6m1714ncpgrg9w4b7crhs1bs6gnq4wbbz3qc";
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
    websocketaf
  ];

  meta = {
    description = "An HTTP library with HTTP/2 support written entirely in OCaml";
    license = lib.licenses.bsd3;
  };
}
