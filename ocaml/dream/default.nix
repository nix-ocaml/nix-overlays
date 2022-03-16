{ lib
, fetchFromGitHub
, buildDunePackage
, bigarray-compat
, camlp-streams
, caqti
, caqti-lwt
, cstruct
, dream-httpaf
, dream-pure
, fmt
, graphql_parser
, graphql-lwt
, lwt
, lwt_ppx
, lwt_ssl
, logs
, magic-mime
, mirage-clock
, mirage-crypto
, mirage-crypto-rng
, multipart_form
, multipart_form-lwt
, ptime
, ssl
, uri
, yojson
  # test-inputs
, bisect_ppx
, alcotest
, crunch
, lambdasoup
, ppx_expect
, ppx_yojson_conv_lib
, reason
, tyxml
, tyxml-jsx
, tyxml-ppx
}:

buildDunePackage rec {
  pname = "dream";
  inherit (dream-pure) src version;

  propagatedBuildInputs = [
    bigarray-compat
    camlp-streams
    caqti
    caqti-lwt
    cstruct
    dream-httpaf
    dream-pure
    fmt
    graphql_parser
    graphql-lwt
    lwt
    lwt_ppx
    lwt_ssl
    logs
    magic-mime
    mirage-clock
    mirage-crypto
    mirage-crypto-rng
    multipart_form
    multipart_form-lwt
    ptime
    ssl
    uri
    yojson
  ];

  buildInputs = [
    bisect_ppx
  ];

  checkInputs = [
    alcotest
    crunch
    lambdasoup
    ppx_expect
    ppx_yojson_conv_lib
    reason
    tyxml
    tyxml-jsx
    tyxml-ppx
  ];
  doCheck = true;

  patches = [ ./upload.patch ];

  preBuild = ''
    rm -rf src/vendor
  '';

  meta = {
    description = "Easy-to-use, feature-complete Web framework without boilerplate";
    license = lib.licenses.mit;
  };
}
