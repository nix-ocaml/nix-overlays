{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildWebsocketaf = args: buildDunePackage ({
    version = "0.0.1-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "websocketaf";
      rev = "b344de3076964e3e5e027e234c72a35ec7f31183";
      sha256 = "1a1c5pvlcbcwh4i824mhj5rphdd3p09l4gwc7cd85ipn820i46yy";
    };
  } // args);
in rec {
  websocketaf = buildWebsocketaf {
    pname = "websocketaf";
    propagatedBuildInputs = [ angstrom faraday httpaf base64 ];
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
    ];
  };
}
