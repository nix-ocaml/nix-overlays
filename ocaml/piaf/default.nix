{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDunePackage {
  pname = "piaf";
  version = "0.0.1-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "piaf";
    rev = "deffeffbbbf13f694fb239df34848f8a1c209d42";
    sha256 = "1xqxjffzr1wgmxfsdfx22gm9fy8mlibyql7lgz9ipzh3xrfbmwa4";
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
    magic-mime
    ssl
    uri
  ];

  meta = {
    description = "Client library for HTTP/1.X / HTTP/2 written entirely in OCaml.";
    license = stdenv.lib.licenses.bsd3;
  };
}
