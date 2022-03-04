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
    rev = "d9924ec";
    sha256 = "sha256-iwr/ymE6EMjExwA9OeUbhDy9pwsffM6IkS33fYSbQ1c=";
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
