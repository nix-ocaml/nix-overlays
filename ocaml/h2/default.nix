{ lib, ocamlPackages, ocamlVersion }:

with ocamlPackages;

let
  buildH2 = args: buildDunePackage (rec {
    version = "0.6.1";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/ocaml-h2/archive/0d05e2a0c512fa17542c00f57921a01c6a3c3c32.tar.gz;
      sha256 = "13hlik4f9srbkw6wbgl6w1mfkqv9rdzzd8azyfdgbmbb5gzfa5nf";
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
