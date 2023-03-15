{ stdenv
, lib
, darwin
, fetchFromGitHub
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
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "piaf";
    rev = "b143c2eadca7f4421bf3da20df7bf47aed0bee11";
    hash = "sha256-Ever8l06+SDzoIKQY2ksq/h9g8H/AaP3WVo+I8QdHT8=";
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
  ] ++ lib.optionals (stdenv.isDarwin && !stdenv.isAarch64) (with darwin.apple_sdk_11_0; [
    Libsystem
  ]);

  meta = {
    description = "An HTTP library with HTTP/2 support written entirely in OCaml";
    license = lib.licenses.bsd3;
  };
}
