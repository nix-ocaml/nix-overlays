{ fetchFromGitHub, lib, buildDunePackage, lwt, eio }:

buildDunePackage {
  pname = "lwt_eio";
  version = "0.5.1";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/lwt_eio/releases/download/v0.5.1/lwt_eio-0.5.1.tbz;
    sha256 = "08bc9yxdzjll0ig1fnkr3wyk0bqx6nkncjfns2xd6m3qg226flkn";
  };

  propagatedBuildInputs = [ lwt eio ];
}
