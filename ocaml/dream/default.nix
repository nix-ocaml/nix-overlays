{ lib
, buildDunePackage
, caqti
, caqti-lwt
, cstruct
, dream-httpaf
, dream-pure
, fmt
, graphql_parser
, graphql-lwt
, lambdasoup
, lwt
, lwt_ppx
, lwt_ssl
, logs
, magic-mime
, markup
, mirage-clock
, mirage-crypto
, mirage-crypto-rng-lwt
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
, ppx_expect
, ppx_yojson_conv_lib
, reason
, tyxml
, tyxml-jsx
, tyxml-ppx
, ocaml
}:

buildDunePackage rec {
  pname = "dream";
  inherit (dream-pure) src version;

  postPatch = ''
    substituteInPlace src/http/adapt.ml \
      --replace-fail \
      "Httpun.Body.Writer.flush body" \
      "fun f -> Httpun.Body.Writer.flush body (fun _r -> f ())" \
       --replace-fail \
      "H2.Body.Writer.flush body" \
      "fun f -> H2.Body.Writer.flush body (fun _r -> f ())"
  '';

  propagatedBuildInputs = [
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
    mirage-crypto-rng-lwt
    multipart_form
    multipart_form-lwt
    ptime
    ssl
    uri
    yojson
    lambdasoup
    markup
  ];

  buildInputs = [
    bisect_ppx
  ];

  checkInputs = [
    alcotest
    crunch
    ppx_expect
    ppx_yojson_conv_lib
    reason
    tyxml
    tyxml-jsx
    tyxml-ppx
  ];

  doCheck = !(lib.versionAtLeast ocaml.version "5.0");
  meta = {
    description = "Easy-to-use, feature-complete Web framework without boilerplate";
    license = lib.licenses.mit;
  };
}
