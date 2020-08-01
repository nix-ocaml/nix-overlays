{ stdenv, ocamlPackages }:

with ocamlPackages;

ocamlPackages.buildDunePackage {
  pname = "piaf";
  version = "0.0.1-dev";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/piaf/archive/76ea85ccd67e1acc6e5d0b07c22a86211c70679f.tar.gz;
    sha256 = "161bgk38jrv3l29m7060dqxjk21jzj2z6qx6aqcbxxw4va9qnkpg";
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
