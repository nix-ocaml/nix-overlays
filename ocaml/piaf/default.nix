{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDunePackage {
  pname = "piaf";
  version = "0.0.1-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "piaf";
    rev = "e99ae27f946017417528163383188ca641595df6";
    sha256 = "1z71y6sw715lcx7yjvx21lpz6hzh1lrfi3335f31p2i2xc8l0zb6";
  };

  propagatedBuildInputs = with ocamlPackages; [
    bigstringaf
    findlib
    httpaf
    httpaf-lwt-unix
    h2
    h2-lwt-unix
    logs
    lwt_ssl
    ssl
    uri
  ];

  meta = {
    description = "Client library for HTTP/1.X / HTTP/2 written entirely in OCaml.";
    license = stdenv.lib.licenses.bsd3;
  };
}
