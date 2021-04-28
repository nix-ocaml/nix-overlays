{ ocamlPackages, fetchFromGitHub, lib }:

with ocamlPackages;
let src = fetchFromGitHub {
  owner = "aantron";
  repo = "dream";
  rev = "42625d123fbe11c2fb3e2dc2dd5926be7cd4a182";
  sha256 = "051pxpmbcg8gy46ccid7fndam6qd87ckivgsj51c1y10wplsdhr3";
  fetchSubmodules = true;
};

in
ocamlPackages.buildDunePackage
{
  pname = "dream";
  version = "1.0.0-dev";
  inherit src;

  propagatedBuildInputs = with ocamlPackages; [
    # base-unix
    base64
    bigarray-compat
    caqti-lwt
    # conf-libev
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
    multipart-form-data
    uri
    yojson
    # vendored dependencies, can we "unvendor" this?
    # gluten
    # gluten-lwt-unix
    # httpaf
    # httpaf-lwt-unix
    # h2
    # h2-lwt-unix
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

  meta = {
    description = " Easy-to-use, feature-complete Web framework without boilerplate";
    license = lib.licenses.mit;
  };
}
