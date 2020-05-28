{ stdenv, fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDunePackage {
  pname = "piaf";
  version = "0.0.1-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "piaf";
    rev = "529bd15bb14529c9e61f57a0791ad313b694d21a";
    sha256 = "1dm6syc3r80lwm572803wzb0ak4q80yjwziy9rcbqq31694czfrx";
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
