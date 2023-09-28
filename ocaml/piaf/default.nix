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
, ocaml
}:

buildDunePackage {
  pname = "piaf";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "piaf";
    rev = "d9c3c4562bd1633320ca2406051bb37a7a792eba";
    hash = "sha256-GH3QmugwyWFfd1cDO7Ue7Q+FjPDRNDKGznRlTwjEFoo=";
  };

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
  ] ++ lib.optionals (stdenv.isDarwin && !stdenv.isAarch64)
    (with darwin.apple_sdk_11_0; [
      Libsystem
    ]);

  meta = {
    description = "An HTTP library with HTTP/2 support written entirely in OCaml";
    license = lib.licenses.bsd3;
  };
}
