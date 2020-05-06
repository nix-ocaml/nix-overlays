{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildWebsocketaf = args: buildDunePackage ({
    version = "0.0.1-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "websocketaf";
      rev = "c002201cdee3a1c81570273a857903840a3d8f89";
      sha256 = "1z8js52hh2gcjj94iqjdsagbpyw5hz61i2wxz06ib1n706iifcdn";
    };
  } // args);
in rec {
  websocketaf = buildWebsocketaf {
    pname = "websocketaf";
    propagatedBuildInputs = [ angstrom faraday gluten httpaf base64 ];
  };

  websocketaf-lwt = buildWebsocketaf {
    pname = "websocketaf-lwt";
    propagatedBuildInputs = [ websocketaf lwt4 digestif ];
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
}
