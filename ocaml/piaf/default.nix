{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDunePackage {
  pname = "piaf";
  version = "0.0.1-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "piaf";
    rev = "3208cf14167ab2a9e0f092c978711c9e16f4485d";
    sha256 = "1n3287jldg31474bk9vj5dzqpk8vf9acrzxrbd905nrdjkn1r6bf";
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
