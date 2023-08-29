{ fetchFromGitHub, lib, buildDunePackage, lwt, eio }:

buildDunePackage {
  pname = "lwt_eio";
  version = "n/a";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/lwt_eio/releases/download/v0.4/lwt_eio-0.4.tbz;
    sha256 = "0ra0fv08nwdw2vyva6c5cqw877bbvni7brfaijh0n1xykd4kzcfa";
  };

  propagatedBuildInputs = [ lwt eio ];
}
