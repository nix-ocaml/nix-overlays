{ lib
, fetchFromGitHub
, buildDunePackage
, alcotest
, angstrom
, base64
, bigarray-compat
, bigstringaf
, caqti-lwt
, cstruct
, digestif
, faraday
, faraday-lwt-unix
, fmt
, graphql_parser
, graphql-lwt
, h2
, h2-lwt-unix
, hmap
, httpaf
, httpaf-lwt-unix
, logs
, lwt
, lwt_ppx
, lwt_ssl
, magic-mime
, mirage-clock
, mirage-crypto
, mirage-crypto-rng
, multipart_form
, ppx_expect
, psq
, result
, uri
, websocketaf
, yojson
}:

buildDunePackage {
  pname = "dream";
  version = "1.0.0-alpha2";
  src = fetchFromGitHub {
    owner = "aantron";
    repo = "dream";
    rev = "055d8196633d1bd9a3280d97a6367a1eabcc7796";
    sha256 = "sha256-DP5a7d5/d8MpUi9QTUAd90vWfZ8MWlJqbyEZXKFu4bg=";
    fetchSubmodules = true;
  };

  # patches = [ ./unvendor.patch ];

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
    websocketaf
    yojson
    # vendored dependencies, can we "unvendor" this?
    # gluten
    # gluten-lwt-unix
    httpaf
    httpaf-lwt-unix
    h2
    h2-lwt-unix
    # hpack
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
