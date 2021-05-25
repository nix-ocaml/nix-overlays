{ ocamlPackages, pkgs, fetchFromGitHub, lib }:

with ocamlPackages;
let src = fetchFromGitHub {
  owner = "aantron";
  repo = "dream";
  rev = "a0dcaf5b4729b24a37c89001bd23343e47190979";
  # Seems like the sha is not checked?
  sha256 = "051pxpmbcg8gy46ccid7fndam6qd87ckivgsj51c1y10wplsdhr3";
  fetchSubmodules = true;
};

in
ocamlPackages.buildDunePackage
{
  pname = "dream";
  version = "1.0.0-alpha2";
  inherit src;

  propagatedBuildInputs = with ocamlPackages; [
    # base-unix
    base64
    bigarray-compat
    caqti-lwt
    # conf-libev
    pkgs.libev
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

  checkInputs = with ocamlPackages; [
    ppx_expect
    alcotest
  ];

  doCheck = true;

  meta = {
    description = "Easy-to-use, feature-complete Web framework without boilerplate";
    license = lib.licenses.mit;
  };
}
