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
    rev = "e48b6b770de0820711343f2eb8b356dfc2cde8a5";
    hash = "sha256-1Y6/YR7TvKpYj4dhMgbUGyq2AZ/EfUQVLdOxdfyCnMc=";
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
