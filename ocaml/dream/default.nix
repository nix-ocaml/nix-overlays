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
, lambdasoup
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
    mirage-crypto-rng-lwt
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

  doCheck = !(lib.versionAtLeast ocaml.version "5.0");

  patches = [ ./upload.patch ];

  # Fix failing expect tests from formatting on the 0.15 JST package line
  prePatch = ''
    substituteInPlace test/expect/pure/stream/stream.ml --replace \
      "(Failure " \
      "Failure("

    substituteInPlace src/sql/dune --replace \
      "caqti-lwt" "caqti-lwt caqti-lwt.unix"

    substituteInPlace src/sql/sql.ml --replace \
      "Caqti_request.exec" \
      "Caqti_request.Infix.(->.) Caqti_type.unit"

    substituteInPlace src/sql/sql.ml --replace \
      "Caqti_lwt.connect_pool" \
      "Caqti_lwt_unix.connect_pool"

    substituteInPlace src/sql/session.ml --replace \
      "R.exec T.(tup4 string string float string)" \
      "R.Infix.(->.) T.(tup4 string string float string) T.unit"

    substituteInPlace src/sql/session.ml --replace \
      "R.find_opt" "R.Infix.(->?)"

    substituteInPlace src/sql/session.ml --replace \
      "R.exec T.(tup2 float string)" \
      "R.Infix.(->.) T.(tup2 float string) T.unit"

    substituteInPlace src/sql/session.ml --replace \
      "R.exec T.(tup2 string string)" \
      "R.Infix.(->.) T.(tup2 string string) T.unit"

    substituteInPlace src/sql/session.ml --replace \
      "R.exec T.string" \
      "R.Infix.(->.) T.string T.unit"

    substituteInPlace src/dune --replace \
      "mirage-crypto-rng.lwt" \
      "mirage-crypto-rng-lwt"

    substituteInPlace src/dream.ml --replace \
      "Mirage_crypto_rng_lwt.initialize" \
      '(fun () -> Mirage_crypto_rng_lwt.initialize (module Mirage_crypto_rng.Fortuna))'
  '';

  preBuild = ''
    rm -rf src/vendor
  '';

  meta = {
    description = "Easy-to-use, feature-complete Web framework without boilerplate";
    license = lib.licenses.mit;
  };
}
