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

  dontDetectOcamlConflicts = true;
  doCheck = !(lib.versionAtLeast ocaml.version "5.0");

  # patches = [ ./upload.patch ];

  # # Fix failing expect tests from formatting on the 0.15 JST package line
  prePatch = ''
    substituteInPlace src/sql/dune --replace \
      "caqti-lwt" "caqti-lwt caqti-lwt.unix"
    substituteInPlace src/sql/sql.ml --replace \
      "Caqti_lwt.connect_pool" \
      "Caqti_lwt_unix.connect_pool"
    substituteInPlace src/sql/sql.ml --replace \
      "?max_size:size" \
      "?pool_config:(Option.map (fun max_size -> Caqti_pool_config.create ~max_size ()) size)"
    substituteInPlace src/sql/sql.ml --replace \
      "Caqti_lwt.Pool" \
      "Caqti_lwt_unix.Pool"
  '';

  preBuild = ''
    rm -rf src/vendor
  '';

  meta = {
    description = "Easy-to-use, feature-complete Web framework without boilerplate";
    license = lib.licenses.mit;
  };
}
