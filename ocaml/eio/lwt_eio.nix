{ buildDunePackage, lwt, eio }:

buildDunePackage {
  pname = "lwt_eio";
  version = "n/a";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/lwt_eio/archive/557403cebb.tar.gz;
    sha256 = "0w5id2s5d530glqrmappl8qba6ki80qgwh0ylb09awypqs8i830w";
  };

  propagatedBuildInputs = [ lwt eio ];
}
