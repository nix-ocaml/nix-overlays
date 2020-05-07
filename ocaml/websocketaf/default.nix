{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildWebsocketaf = args: buildDunePackage ({
    version = "0.0.1-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "websocketaf";
      rev = "929ef16ecf686e88968f971ac84910cb12f9b219";
      sha256 = "1lzk5gnbxxmp9sc2yvaq02av7kgw8i54vbdfywvjh0jwpz8jsj7d";
    };
  } // args);
in rec {
  websocketaf = buildWebsocketaf {
    pname = "websocketaf";
    propagatedBuildInputs = [ angstrom faraday gluten httpaf base64 ];
  };

  websocketaf-lwt = buildWebsocketaf {
    pname = "websocketaf-lwt";
    propagatedBuildInputs = [ websocketaf gluten-lwt lwt4 digestif ];
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
