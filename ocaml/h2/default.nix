{ lib, ocamlPackages, ocamlVersion }:

with ocamlPackages;
let
  buildH2 = args: buildDunePackage (rec {
    version = "0.8.0-dev";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/ocaml-h2/archive/93c7e071a0bf8e0b7360cc9d7dc4532cbe0943e9.tar.gz;
      sha256 = "16jvwbifcq26p6g8w5q49biqjfs2yw82dryfls5zd9cblawzifsb";
    };
  } // args);
in
{
  hpack = buildH2 {
    pname = "hpack";
    propagatedBuildInputs = [ angstrom faraday ];
  };

  h2 = buildH2 {
    pname = "h2";
    propagatedBuildInputs = [
      angstrom
      faraday
      base64
      psq
      hpack
      httpaf
    ];
  };

  h2-lwt = buildH2 {
    pname = "h2-lwt";
    propagatedBuildInputs = [ gluten-lwt h2 lwt ];
  };

  h2-lwt-unix = buildH2 {
    pname = "h2-lwt-unix";
    propagatedBuildInputs = [
      gluten-lwt-unix
      h2-lwt
      faraday-lwt-unix
      lwt_ssl
    ];
  };
} // (if (lib.versionOlder "4.08" ocamlVersion) then {
  h2-async = buildH2 {
    pname = "h2-async";
    doCheck = false;
    propagatedBuildInputs = [
      h2
      async
      gluten-async
      faraday-async
      async_ssl
    ];
  };

  h2-mirage = buildH2 {
    pname = "h2-mirage";
    doCheck = false;
    propagatedBuildInputs = [
      conduit-mirage
      h2-lwt
      gluten-mirage
    ];
  };
} else { })
