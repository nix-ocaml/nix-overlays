{ lib, ocamlPackages, ocamlVersion }:

with ocamlPackages;
let
  buildWebsocketaf = args: buildDunePackage ({
    version = "0.0.1-dev";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/websocketaf/archive/fb9926b6f653252e4ba5009bbb171a11c0e4e6fc.tar.gz;
      sha256 = "105cbpcdbsx11p63v3s2cld1sixhm5kjjj4g6k9jvi2gs2p808hg";
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
