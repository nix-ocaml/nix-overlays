{ lib, ocamlPackages, ocamlVersion }:

with ocamlPackages;
let
  buildWebsocketaf = args: buildDunePackage ({
    version = "0.0.1-dev";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/websocketaf/archive/248a2cb.tar.gz;
      sha256 = "1zpbfsh15933pcjam6pxg9fx710hypi2l6p1rgccrvjjkin96yyi";
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
