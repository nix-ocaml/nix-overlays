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
, camlp-streams
}:

buildDunePackage {
  pname = "dream";
  version = "1.0.0-alpha2";
  src = fetchFromGitHub {
    owner = "EduardoRFS";
    repo = "dream";
    rev = "bd4c4b09b0ace2144384f97848bcfd6ad0856e7e";
    sha256 = "sha256-8vD8qIk4TZ3d1h0E6ACmAyCpT58WwJCgmjjNNH/JDQM=";
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
    camlp-streams
  ];

  /*
  postPatch = ''
    substituteInPlace ./src/eml/dune --replace "(modules eml)" "(modules eml) (libraries camlp-streams)"
  '';
  */

  checkInputs = [ ppx_expect alcotest ];
  doCheck = true;

  meta = {
    description = "Easy-to-use, feature-complete Web framework without boilerplate";
    license = lib.licenses.mit;
  };
}
