{ stdenv
, lib
, fetchFromGitHub
, alcotest
, alcotest-lwt
, buildDunePackage
, dune-site
, h2-lwt-unix
, httpaf-lwt-unix
, ipaddr
, logs
, lwt_ssl
, magic-mime
, multipart_form
, sendfile
, uri
}:

buildDunePackage {
  pname = "piaf-lwt";
  version = "n/a";
  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/piaf/archive/83ca1ec.tar.gz;
    sha256 = "1fa0qdfp35hkq2hnc5jxm6xklbvvxg731nkx977b3nj19pcakyz1";
  };

  doCheck = false;
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
    sendfile
  ];

  meta = {
    description = "An HTTP library with HTTP/2 support written entirely in OCaml";
    license = lib.licenses.bsd3;
  };
}
