{ buildDunePackage, lwt, eio }:

buildDunePackage {
  pname = "lwt_eio";
  version = "n/a";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/lwt_eio/archive/557403cebb.tar.gz;
    sha256 = "0wbqbjx8l7v49646ckxv52kg5r5nqz712drm53nwcf2hrm75b481";
  };

  propagatedBuildInputs = [ lwt eio ];
}
