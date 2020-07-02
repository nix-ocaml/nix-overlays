{ lib, fetchFromGitHub, ocamlPackages, ocamlVersion }:

with ocamlPackages;

let
  buildWebsocketaf = args: buildDunePackage ({
    version = "0.0.1-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "websocketaf";
      rev = "fb9926b6f653252e4ba5009bbb171a11c0e4e6fc";
      sha256 = "1hsym4q9763ml6p96klmi9230pp2dgf4nhr9zgzd5kqh8dy86zbv";
    };
  } // args);

in rec {
  websocketaf = buildWebsocketaf {
    pname = "websocketaf";
    propagatedBuildInputs = [ angstrom faraday gluten httpaf base64 ];
  };

  websocketaf-lwt = buildWebsocketaf {
    pname = "websocketaf-lwt";
    propagatedBuildInputs = [ websocketaf gluten-lwt lwt digestif ];
  };

  websocketaf-lwt-unix = buildWebsocketaf {
    pname = "websocketaf-lwt-unix";
    propagatedBuildInputs = [
      websocketaf
      websocketaf-lwt
      faraday-lwt-unix
      gluten-lwt-unix
    ];
  };
} // (if (lib.versionOlder "4.08" ocamlVersion) then {
    websocketaf-async = buildWebsocketaf {
      pname = "websocketaf-async";
      doCheck = false;
      propagatedBuildInputs = [
        websocketaf
        async
        gluten-async
        faraday-async
        async_ssl
        digestif
      ];
    };

    websocketaf-mirage = buildWebsocketaf {
      pname = "websocketaf-mirage";
      doCheck = false;
      propagatedBuildInputs = [
        conduit-mirage
        websocketaf-lwt
        gluten-mirage
      ];
    };
  } else {})
