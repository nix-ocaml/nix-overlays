{ lib
, fetchFromGitHub
, buildDunePackage
, base64
, bigarray-compat
, caqti-lwt
, cstruct
, fmt
, graphql_parser
, graphql-lwt
, hmap
, lwt
, lwt_ppx
, lwt_ssl
, logs
, magic-mime
, mirage-crypto
, mirage-crypto-rng
, multipart_form
, uri
, yojson
, angstrom
, bigstringaf
, digestif
, faraday
, faraday-lwt-unix
, psq
, result
, ppx_expect
, alcotest
}:

buildDunePackage {
  pname = "dream";
  version = "1.0.0-alpha2";
  src = fetchFromGitHub {
    owner = "aantron";
    repo = "dream";
    rev = "a0dcaf5b4729b24a37c89001bd23343e47190979";
    sha256 = "198d23hfnb552ynaj55xlxjaca4v65sbhff3bdvrwl7j362r3spr";
    fetchSubmodules = true;
  };

  version = "1.0.0-dev";
  inherit src;

  patches = [ ./unvendor.patch ];

  propagatedBuildInputs = [
    # base-unix
    base64
    bigarray-compat
    caqti-lwt
    cstruct
    fmt
    graphql_parser
    graphql-lwt
    hmap
    lwt
    lwt_ppx
    lwt_ssl
    logs
    magic-mime
    mirage-crypto
    mirage-crypto-rng
    mirage-clock
    (multipart_form.override { upstream = true; })
    uri
    yojson
    # vendored dependencies, can we "unvendor" this?
    # gluten
    # gluten-lwt-unix
    httpaf
    httpaf-lwt-unix
    h2
    h2-lwt-unix
    # hpack
    # websocketaf
    # dependencies of vendored packages
    angstrom
    bigstringaf
    digestif
    faraday
    faraday-lwt-unix
    psq
    result
  ];

  checkInputs = [ ppx_expect alcotest ];
  doCheck = true;

  meta = {
    description = "Easy-to-use, feature-complete Web framework without boilerplate";
    license = lib.licenses.mit;
  };
}
