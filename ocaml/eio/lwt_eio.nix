{ fetchFromGitHub, lib, buildDunePackage, lwt, eio }:

buildDunePackage {
  pname = "lwt_eio";
  version = "n/a";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/lwt_eio/releases/download/v0.5/lwt_eio-0.5.tbz;
    sha256 = "1dr4f93pgrg49y51kaxqrm47zblmzhb5c1qbbpqh5ghy825gwfaa";
  };

  propagatedBuildInputs = [ lwt eio ];
}
