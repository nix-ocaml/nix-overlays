{ lib, ocamlPackages, ocamlVersion }:

with ocamlPackages;

let
  buildH2 = args: buildDunePackage (rec {
    version = "0.7.0";
    src = builtins.fetchurl {
      url = "https://github.com/anmonteiro/ocaml-h2/releases/download/${version}/h2-${version}.tbz";
      sha256 = "0pyzj6801nva86nc3bfgzq79jszylh2ihjc99dx56agbj21hlif9";
    };
  } // args);
in {
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
  } else {})
