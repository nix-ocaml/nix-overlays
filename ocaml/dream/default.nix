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

  postPatch = ''
    substituteInPlace src/http/shared/dune --replace "dream-httpaf." ""
    substituteInPlace src/http/dune --replace "dream-httpaf." ""
    substituteInPlace src/http/adapt.ml \
      --replace "[ \`write ] H2.Body.t" "H2.Body.Writer.t" \
      --replace "H2.Body.write_string" "H2.Body.Writer.write_string" \
      --replace "H2.Body.write_bigstring" "H2.Body.Writer.write_bigstring" \
      --replace "H2.Body.flush" "H2.Body.Writer.flush" \
      --replace "H2.Body.close_writer" "H2.Body.Writer.close"
    substituteInPlace src/http/http.ml \
      --replace "H2.Body.schedule_read" "H2.Body.Reader.schedule_read" \
      --replace "H2.Body.close_reader" "H2.Body.Reader.close"
  '';

  preBuild = ''
    rm -rf src/vendor
  '';

  meta = {
    description = "Easy-to-use, feature-complete Web framework without boilerplate";
    license = lib.licenses.mit;
  };
}
