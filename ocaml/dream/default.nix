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
, fmt
, graphql_parser
, graphql-lwt
, hmap
, logs
, lwt
, lwt_ppx
, lwt_ssl
, magic-mime
, mirage-clock
, mirage-crypto
, mirage-crypto-rng
, multipart_form
, multipart_form-lwt
, ppx_expect
, psq
, result
, uri
, yojson
, camlp-streams
, dream-pure
, dream-httpaf
, httpaf
}:

buildDunePackage rec {
  pname = "dream";
  inherit (dream-pure) src version;

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
    multipart_form
    multipart_form-lwt
    uri
    yojson
    dream-pure
    dream-httpaf
    httpaf
  ];

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

  checkInputs = [ ppx_expect alcotest ];
  doCheck = true;

  meta = {
    description = "Easy-to-use, feature-complete Web framework without boilerplate";
    license = lib.licenses.mit;
  };
}
