{ stdenv
, lib
, fetchFromGitHub
, alcotest
, alcotest-lwt
, buildDunePackage
, dune-site
, h2-lwt-unix
, httpaf-lwt-unix
, multipart_form
, ipaddr
, logs
, lwt_ssl
, magic-mime
, uri
}:

buildDunePackage {
  pname = "piaf";
  version = "0.0.1-dev";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "piaf";
    rev = "a9da7c0";
    sha256 = "07x9642mjd87z38sj5cs7smzdyrrd80g8bcgh3n5wff7891dnaw5";
  };

  doCheck = true;
  checkInputs = [ alcotest alcotest-lwt dune-site ];

  propagatedBuildInputs = [
    logs
    lwt_ssl
    uri
    ipaddr
    magic-mime

    multipart_form
    httpaf-lwt-unix
    h2-lwt-unix
  ];

  meta = {
    description = "An HTTP library with HTTP/2 support written entirely in OCaml";
    license = lib.licenses.bsd3;
  };
}
