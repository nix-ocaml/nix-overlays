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
    rev = "de171771ac817a307baf2e824c7e819fa168053d";
    hash = "sha256-IJhPLC0J7lipxhHkxLcNu8zmv2rMVovVczpnXx9eL6c=";
  };

  doCheck = ocaml.version != "5.0.0" && stdenv.isLinux;
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
