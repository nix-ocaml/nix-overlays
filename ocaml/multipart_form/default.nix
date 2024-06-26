{
  upstream ? false,
  lib,
  fetchFromGitHub,
  buildDunePackage,
  unstrctrd,
  lwt,
  ocaml,
  prettym,
  logs,
  ke,
  bigstringaf,
  astring,
  faraday,
  base64,
  pecu,
  rosetta,
  rresult,
  uutf,
  fmt,
  angstrom,
  alcotest,
}:

let
  upstream_src = builtins.fetchurl {
    url = "https://github.com/dinosaure/multipart_form/releases/download/v0.6.0/multipart_form-0.6.0.tbz";
    sha256 = "05i10ql2zkf0v1rif3v08sas1rm1d1xghnndcx0svyng4g1jkqx0";
  };
  upstream_version = "0.4.1";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "multipart_form";
    rev = "06a86ad395a4f09cdf1ac4fd1f15993521e7ac47";
    hash = "sha256-+bkJbwwLbYL3CTSSv6XxTaYGRRe3rlPTYRxeh1l4cXk=";
  };
  version = "0.5.0-dev";

in

buildDunePackage {
  pname = "multipart_form";

  version = if upstream then upstream_version else version;

  src = if upstream then upstream_src else src;

  propagatedBuildInputs = [
    base64
    pecu
    rosetta
    rresult
    uutf
    fmt
    angstrom
    bigstringaf
    ke
    logs
    prettym
    unstrctrd
    faraday
  ];

  doCheck = !upstream;

  checkInputs = [
    alcotest
    rosetta
  ];
}
