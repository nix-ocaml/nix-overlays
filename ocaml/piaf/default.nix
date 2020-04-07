{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDunePackage {
  pname = "piaf";
  version = "0.0.1-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "piaf";
    rev = "395b4c0a73bc3db7e73bd1087cb53643bfdb67e9";
    sha256 = "0vm7qlv6nngs6q4n3wlsc4b5b7i09sb6jqqyw9w5ij0aa46sgyg8";
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
