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
    rev = "b388de4a3a9b16841bc924f04639a24c60a8e8fc";
    hash = "sha256-tO5pkbSbenub6Obc0PaSYokWwv6+cLTL/zBOHM5gjk0=";
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
  ] ++ lib.optionals (stdenv.isDarwin && !stdenv.isAarch64)
    (with darwin.apple_sdk_11_0; [
      Libsystem
    ]);

  meta = {
    description = "An HTTP library with HTTP/2 support written entirely in OCaml";
    license = lib.licenses.bsd3;
  };
}
