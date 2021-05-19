{ lib, ocamlPackages, ocamlVersion }:

with ocamlPackages;
let
  buildWebsocketaf = args: buildDunePackage ({
    version = "0.0.1-dev";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/websocketaf/archive/d75942f936821231cb4ff46b95cf2753d7329233.tar.gz;
      sha256 = "14y3cj3sd8kgijj7mw20rfr8hr7asj6mll6n4b9sjj02pqhfqqaz";
    };
  } // args);

in
{
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
} else { })
